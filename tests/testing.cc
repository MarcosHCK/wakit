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
#include <cstddef>
#include <gio/gio.h>
#include <iterator>
#include <numeric>
#include <tests/bits.h>
#include <tests/testing.h>
#include <utility>
using namespace testing;

struct _TestingRefCountMonitor { GObject parent; gboolean* destroyed; };
struct _TestingRefCountMonitorClass { GObjectClass parent; };

typedef struct _TestingRefCountMonitorClass TestingRefCountMonitorClass;
G_DEFINE_TYPE (TestingRefCountMonitor, testing_ref_count_monitor, G_TYPE_OBJECT)

static void testing_ref_count_monitor_class_finalize (GObject* pself)
{

  auto self = (TestingRefCountMonitor*) pself;
  self->destroyed = (self->destroyed == NULL) ? NULL : (*self->destroyed = TRUE, nullptr);
G_OBJECT_CLASS (testing_ref_count_monitor_parent_class)->finalize (pself);
}

static void testing_ref_count_monitor_class_set_property (GObject* pself, guint property_id, const GValue* value, GParamSpec* pspec)
{

  switch (auto self = (TestingRefCountMonitor*) pself; property_id)
    {

    case 1: self->destroyed = (gboolean*) g_value_get_pointer (value);
      break;

    default: G_OBJECT_WARN_INVALID_PROPERTY_ID (pself, property_id, pspec);
      break;
    }
}

static void testing_ref_count_monitor_class_init (TestingRefCountMonitorClass* klass)
{

  G_OBJECT_CLASS (klass)->finalize = testing_ref_count_monitor_class_finalize;
  G_OBJECT_CLASS (klass)->set_property = testing_ref_count_monitor_class_set_property;

  constexpr auto flag1 = (GParamFlags) G_PARAM_CONSTRUCT_ONLY;
  constexpr auto flag2 = (GParamFlags) G_PARAM_STATIC_STRINGS;
  constexpr auto flag3 = (GParamFlags) G_PARAM_WRITABLE;
  constexpr auto flags = (GParamFlags) (flag1 | flag2 | flag3);

  g_object_class_install_property (G_OBJECT_CLASS (klass), 1, g_param_spec_pointer ("destroyed", "destroyed", "destroyed", flags));
}

static void testing_ref_count_monitor_init (TestingRefCountMonitor* self)
{
  self->destroyed = NULL;
}

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

void testing::g_test_rand_data (guint8* data, size_t size)
{

  for (decltype (size) i = 0; i < (size >> bits::log2_v<sizeof (gint32)>); ++i)
    data [i] = g_test_rand_int ();

  if (auto last = size & ~bits::mask_v<sizeof (gint32), size_t>; size != last)
    {

      guint32 left = g_test_rand_int ();

      for (decltype (size) i = last; i < size; ++i, left >>= 8)
        data [i] = left & 0xff;
    }
}

std::pair<guint8*, gsize> testing::g_test_rand_data (size_t max, size_t min) noexcept
{

  auto size = max == min ? min : g_test_rand_int_range (min, max);
  auto full = bits::align_upto<sizeof (gint32)> (size);
  auto data = g_new (guint8, full);

  for (decltype (full) i = 0; i < (full >> bits::log2_v<sizeof (gint32)>); ++i)
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

template<int N, int... Is> static inline constexpr std::array<char, N + 1> __make_char_range (char first, std::integer_sequence<int, Is ...> const&)
{
  auto ar = std::array<char, N + 1> { ((char) (first + Is)) ..., 0 };
return ar;
}

template<int N> static inline constexpr std::array<char, N + 1> __make_char_range (char first)
{
  auto ar = __make_char_range<N> (first, std::make_integer_sequence<int, N> ());
return ar;
}

template<char first, char last> requires (last > first)
  struct char_range { static inline constexpr auto value = __make_char_range<last - first> (first); };

template<char first, char last> requires (last > first)
  static inline constexpr std::array<char, last - first + 1> char_range_v = char_range<first, last>::value;

static auto _next_op_range (std::string pc, decltype (pc.size ()) last)
{

  if (auto left = pc.size () - last; left < 3)

    return (size_t) left;
  else
    return (size_t) g_test_rand_uint64_range (2, left);
}

static auto _make_op_string (int max_depth)
{

  static auto charset = char_range_v<'a', 'z'>;

  unsigned n;
  std::string ar { "/" };
  std::string pc = g_test_rand_string (max_depth, 0, charset.data ());

  if (pc.size () < 4)
    return ar;

  ar.reserve (1 + (n = g_test_rand_int_range (0, max_depth)));

  std::copy (pc.begin (), pc.end (), std::back_inserter (ar));

  for (decltype (pc.size ()) last = 0; last < (pc.size () - 1); last += _next_op_range (pc, last))
    ar [last] = '/';

return ar;
}

static auto _make_sr_container (const GVariantType* vtype, int max_width) noexcept
{

  unsigned n;

  std::vector<GVariant*> ar;

  ar.reserve (n = g_test_rand_int_range (0, max_width));

  for (decltype (n) i = 0; i < n; ++i)

    ar.push_back (g_test_rand_variant (vtype, max_width));

return ar;
}

static auto _make_vr_container (const GVariantType* vtype, int max_width) noexcept
{

  std::vector<GVariant*> ar;

  for (auto child = g_variant_type_first (vtype); NULL != child; child = g_variant_type_next (child))

    ar.push_back (g_test_rand_variant (child, max_width));

return ar;
}

GVariant* testing::g_test_rand_variant (const GVariantType* vtype, int max_depth, int max_width) noexcept
{

  switch (auto c = g_variant_type_peek_string (vtype) [0]; c)
    {

    case '(': { auto var = _make_vr_container (vtype, max_width);
                return g_variant_new_tuple (var.data (), var.size ()); }

    case '{': { auto var = _make_vr_container (vtype, max_width);
                return g_variant_new_dict_entry (var.data () [0], var.data () [1]); }

    case 'a': { auto vat = g_variant_type_element (vtype);
                auto var = _make_sr_container (vat, max_width);
                return g_variant_new_array (vat, var.data (), var.size ()); }

    case 'b': return g_variant_new_boolean (g_test_rand_bit ());
    case 'd': return g_variant_new_double (g_test_rand_double ());

    case 'g': { auto vat = g_test_rand_variant_type ("({abdghimnoqstuvxy", 18, 10, max_width);
                auto vas = g_variant_type_dup_string (vat);
                auto var = g_variant_new_signature (vas);
                return (g_free (vas), g_variant_type_free (vat), var); }

    case 'h': return g_variant_new_handle (g_test_rand_int ());
    case 'i': return g_variant_new_int32 (g_test_rand_int ());

    case 'm': { auto has = g_test_rand_bit ();
                auto vat = g_variant_type_element (vtype);
                auto va1 = ! has ? nullptr : g_test_rand_variant (vat, max_depth, max_width);
                return g_variant_new_maybe (vat, va1); }

    case 'n': return g_variant_new_int16 (g_test_rand_int_range (G_MININT16, G_MAXINT16));

    case 'o': { auto oph = _make_op_string (max_width);
                return g_variant_new_object_path (oph.c_str ()); }

    case 'q': return g_variant_new_uint16 (g_test_rand_int_range (0, G_MAXUINT16));

    case 's': { auto vas = g_test_rand_string (max_width, 0);
                return g_variant_new_string (vas.c_str ()); }

    case 't': return g_variant_new_uint64 (g_test_rand_uint64 ());
    case 'u': return g_variant_new_uint32 (g_test_rand_uint32 ());

    case 'v':

      if (max_depth == 0)
        g_error ("can not go deeper");

        { auto vat = g_test_rand_variant_type ("({abdghimnoqstuvxy", 18, max_depth - 1, max_width);
          auto var = g_test_rand_variant (vat, max_depth, max_width);
          return g_variant_new_variant (var); }

    case 'x': return g_variant_new_int64 (g_test_rand_int64 ());
    case 'y': return g_variant_new_byte ((guint8) g_test_rand_int_range (0, G_MAXUINT8));

    default:
      g_error ("invalid possible char type '%i'", c);
    }
}

static auto _make_ar_container (const char* possible, ssize_t n_possible, int max_depth, int max_width) noexcept
{

  unsigned n;

  GPtrArray* ar =
  g_ptr_array_sized_new (n = g_test_rand_int_range (0, max_width));
  g_ptr_array_set_free_func (ar, (GDestroyNotify) g_variant_type_free);
 
  for (decltype (n) i = 0; i < n; ++i)

    g_ptr_array_add (ar, g_test_rand_variant_type (possible, n_possible, max_depth, max_width));

return ar;
}

static auto _next_no_container (const char* possible, ssize_t n, unsigned idx) noexcept
{

  n = 0 < n ? n : strlen (possible);

  if (auto iter = std::find_if (possible + idx, possible + n, [](char c)
                    { return ! ('a' == c || 'm' == c || 'v' == c || '(' == c || '{' == c); }); iter != (possible + n))

    return *iter;
  else

    if (auto iter2 = std::find_if (possible, possible + idx, [](char c)
                       { return ! ('a' == c || 'm' == c || 'v' == c || '(' == c || '{' == c); }); iter != (possible + idx))

      return *iter2;
    else
      g_error ("can not find a basic type (among '%.*s')", (int) n, possible);
}

GVariantType* testing::g_test_rand_variant_type (const char* possible, ssize_t n_possible, int max_depth, int max_width) noexcept
{

  g_return_val_if_fail (NULL != possible, NULL);
  g_return_val_if_fail (0 < n_possible, NULL);
  g_return_val_if_fail (0 <= max_depth, NULL);
  g_return_val_if_fail (0 <= max_width, NULL);
  char c;

  switch (auto idx = (unsigned) g_test_rand_int_range (0, n_possible); (c = possible [idx]))
    {

    case '(':

      if (max_depth == 0)

        { auto chr = _next_no_container (possible, n_possible, idx);
          return g_test_rand_variant_type (&chr, 1, max_depth, max_width); }
      else
        { auto arr = _make_ar_container (possible, n_possible, max_depth - 1, max_width);
          auto vat = g_variant_type_new_tuple ((const GVariantType**) arr->pdata, arr->len);
          return (g_ptr_array_unref (arr), vat); }

    case '{':

      if (max_depth == 0)

        { auto chr = _next_no_container (possible, n_possible, idx);
          return g_test_rand_variant_type (&chr, 1, max_depth, max_width); }
      else
        { auto va1 = g_test_rand_variant_type (possible, n_possible, 0, max_width);
          auto va2 = g_test_rand_variant_type (possible, n_possible, max_depth - 1, max_width);
          auto vat = g_variant_type_new_dict_entry (va1, va2);
          return (g_variant_type_free (va1), g_variant_type_free (va2), vat); }

    case 'a':

      if (max_depth == 0)

        { auto chr = _next_no_container (possible, n_possible, idx);
          return g_test_rand_variant_type (&chr, 1, max_depth, max_width); }
      else
        { auto va1 = g_test_rand_variant_type (possible, n_possible, max_depth - 1, max_width);
          auto vat = g_variant_type_new_array (va1);
          return (g_variant_type_free (va1), vat); }

    case 'b': G_GNUC_FALLTHROUGH;
    case 'd': G_GNUC_FALLTHROUGH;
    case 'g': G_GNUC_FALLTHROUGH;
    case 'h': G_GNUC_FALLTHROUGH;
    case 'i': { char cs [2] = { c, 0 }; return g_variant_type_new (cs); }

    case 'm':

      if (max_depth == 0)

        { auto chr = _next_no_container (possible, n_possible, idx);
          return g_test_rand_variant_type (&chr, 1, max_depth, max_width); }
      else
        { auto va1 = g_test_rand_variant_type (possible, n_possible, max_depth - 1, max_width);
          auto vat = g_variant_type_new_array (va1);
          return (g_variant_type_free (va1), vat); }

    case 'n': G_GNUC_FALLTHROUGH;
    case 'o': G_GNUC_FALLTHROUGH;
    case 'q': G_GNUC_FALLTHROUGH;
    case 's': G_GNUC_FALLTHROUGH;
    case 't': G_GNUC_FALLTHROUGH;
    case 'u': { char cs [2] = { c, 0 }; return g_variant_type_new (cs); }

    case 'v':

      if (max_depth > 0)

        { char cs [2] = { c, 0 }; return g_variant_type_new (cs); }
      else
        { auto chr = _next_no_container (possible, n_possible, idx);
          return g_test_rand_variant_type (&chr, 1, max_depth, max_width); }

    case 'x': G_GNUC_FALLTHROUGH;
    case 'y': { char cs [2] = { c, 0 }; return g_variant_type_new (cs); }

    default:
      g_error ("invalid possible char type '%i'", c);
    }
}

gchar* testing::g_read_offsource (const gchar* name, gsize* out_length)
{

  GError* error = nullptr;
  GFile* file = nullptr;
  gchar* data = nullptr;

  g_file_load_contents (file = g_file_new_build_filename (SOURCE_DIR, name, NULL), NULL, &data, out_length, NULL, &error);

  if (g_object_unref (file); G_UNLIKELY (NULL != error))
    {

      const guint code = error->code;
      const gchar* domain = g_quark_to_string (error->domain);
      const gchar* message = error->message;

      g_error ("g_read_offsource ('%s')!: %s: %u: %s", name, domain, code, message);
    }
return data;
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