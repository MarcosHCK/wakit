/* Copyright (C) 2025-2026 MarcosHCK
 * This file is part of wakit.
 *
 * wakit is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wakit is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */
#include <config.h>
#include <algorithm>
#include <cmath>
#include <numeric>
#include <tests/testing.hh>
#include <utility/bits.hh>
using namespace testing;
using namespace wakit;

static void __call_function (gconstpointer data)
{

  (*(const std::function<void()>*) data) ();
  return;

  try
    { (*(const std::function<void()>*) data) (); }
  catch (...)
    { /* libc++ has not std::stacktrace implementation for now */ }
}

static void __destroy_function (gpointer data)
{
  delete (std::function<void()>*) data;
}

void testing::g_test_add_function (const char* path, std::function<void()>&& func)
{

  auto ptr = new std::function<void()> (std::move (func));
  g_test_add_data_func_full (path, ptr, __call_function, __destroy_function);
}

class printer
{

  GString* _str = nullptr;
public:

  inline ~printer ()
    {
      if (nullptr != _str)
        g_string_free (_str, TRUE);
    }

  inline printer (): _str (g_string_sized_new (256))
    { }

  inline void append (char c) noexcept
    {

      g_string_append_c (_str, c);
    }

  inline void append (const char* fmt, ...) noexcept G_GNUC_PRINTF (2, 3)
    {

      va_list l;
      va_start (l, fmt);

      g_string_append_vprintf (_str, fmt, l);
      va_end (l);
    }

  inline void append (const char* fmt, va_list l) noexcept G_GNUC_PRINTF (2, 0)
    {

      g_string_append_vprintf (_str, fmt, l);
    }

  inline void log (GLogLevelFlags log_level = G_LOG_LEVEL_DEBUG) noexcept
    {

      g_test_message ("%.*s", (int) _str->len, _str->str);
      g_string_truncate (_str, 0);
    }

  inline size_t size () noexcept
    {
      return _str->len;
    }

  inline gchar* steal ()
    {
      auto value = g_string_free_and_steal (_str);
    return (_str = nullptr, value);
    }

  inline void truncate (gsize to) noexcept
    {
      g_string_truncate (_str, to);
    }
};

template<unsigned N, typename T> static inline T pow_n (T value)
{

  if constexpr (1 == N)

    return value;
  else
    return pow_n<(N >> 1)> (value) * pow_n<N - (N >> 1)> (value);
}

static inline gdouble kurtosis (const std::vector<gdouble>& data, gdouble mean, gdouble stddev) noexcept
{

  gdouble sum = 0;

  if (0 == stddev)
    return 0;

  for (gdouble value: data)
    sum += pow_n<4> ((value - mean) / stddev);

return sum / data.size () - 3.;
}

static inline gdouble skewness (const std::vector<gdouble>& data, gdouble mean, gdouble stddev) noexcept
{

  gdouble sum = 0;

  if (0 == stddev)
    return 0;

  for (gdouble value: data)
    sum += pow_n<3> ((value - mean) / stddev);

return sum / (gdouble) data.size ();
}

static inline gdouble percentile (const std::vector<gdouble>& sorted, double per) noexcept
{

  if (sorted.empty ())
    return 0;

  auto rank = (per / 100.) * (gdouble) sorted.size ();

  auto lower_index = (size_t) std::floor (rank);
  auto upper_index = (size_t) std::floor (rank);

  if (lower_index == upper_index)
    return sorted [lower_index];

  auto weight = rank - lower_index;
  auto value = sorted [lower_index] * (1 - weight) + sorted [upper_index] * weight;
return value;
}

gchar* testing::g_test_analyze_times (const std::vector<gdouble>& times) noexcept
{

  auto count = times.size ();
  auto sorted = std::vector<gdouble> (times);

  std::sort (sorted.begin (), sorted.end ());

  printer p;
  double mean, sum, q1, q2, q3;

  p.append ("min: %lf\n", sorted.front ());
  p.append ("max: %lf\n", sorted.back ());
  p.append ("range: %lf\n", sorted.back () - sorted.front ());

  sum = std::accumulate (times.begin (), times.end (), 0.);

  p.append ("mean: %lf\n", mean = sum / (gdouble) count);
  p.append ("median: %lf\n", q2 = percentile (sorted, 50.));

  p.append ("quartiles\n");
  p.append ("  " "75%%: %lf\n", q1 = percentile (sorted, 75.));
  p.append ("  " "50%%: %lf\n", q2);
  p.append ("  " "25%%: %lf\n", q3 = percentile (sorted, 25.));
  p.append ("  " "iqr: %lf\n", q3 - q1);

  p.append ("percentiles\n");
  p.append ("  " "95%%: %lf\n", percentile (sorted, 98.));
  p.append ("  " "90%%: %lf\n", percentile (sorted, 90.));
  p.append ("  " "80%%: %lf\n", percentile (sorted, 80.));
  p.append ("  " "10%%: %lf\n", percentile (sorted, 10.));

  sum = 0;

  for (gdouble value: times)
    sum += pow_n<2> (value - mean);

  auto stddev = sum / (gdouble) (count - 1);
  auto stddev_p = sum / (gdouble) count;

  p.append ("variance: %lf\n", stddev);
  p.append ("standard variance: %lf\n", stddev = std::sqrt (stddev));

  p.append ("population variance: %lf\n", stddev_p);
  p.append ("population standard variance: %lf\n", stddev_p = std::sqrt (stddev_p));

  p.append ("skewness: %lf\n", skewness (times, mean, stddev));
  p.append ("kurtosis: %lf\n", kurtosis (times, mean, stddev));

return (p.truncate (p.size () - 1), p.steal ());
}

std::pair<guint8*, gsize> testing::g_test_rand_data (size_t max, size_t min) noexcept
{

  auto size = max == min ? min : g_test_rand_int_range (min, max);
  auto full = align_upto<sizeof (gint32)> (size);
  auto data = g_new (guint8, full);

  for (decltype (full) i = 0; i < (full >> log2_v<sizeof (gint32)>); ++i)
    data [i] = g_test_rand_int ();

return { data, size };
}

std::string testing::g_test_rand_string (size_t max, size_t min, const char* charset) noexcept
{
  std::string buffer;
  size_t length;

  buffer.resize (length = min == max ? max : g_test_rand_int_range (min, max));

  if (nullptr == charset)

    for (size_t i = 0; i < length; ++i)
      buffer.data () [i] = g_test_rand_int_range (0x21, 0x7f);
  else
    for (size_t charset_sz = strlen (charset), i = 0; i < length; ++i)
      buffer.data () [i] = charset [ g_test_rand_int_range (0, charset_sz) ];

return buffer;
}

gchar* testing::g_str_indent_up (const gchar* value, guint by)
{

  GString* g_str;
  gchar* prefix = NULL;
  guint n_prefix = 1 + by * 2;

  g_str = g_string_new (value);
  prefix = g_new (char, n_prefix);

  prefix [0] = '\n';
  prefix [n_prefix] = '\0';

  for (decltype (n_prefix) i = 1; i < n_prefix; ++i)
    prefix [i] = ' ';

  g_string_replace (g_str, "\n", prefix, 0);
  g_string_prepend_len (g_str, &prefix [1], n_prefix - 1);

return g_string_free_and_steal (g_str);
}