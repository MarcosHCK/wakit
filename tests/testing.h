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
#pragma once
#include <array>
#include <cstddef>
#include <exception>
#include <functional>
#include <glib-object.h>
#include <string>
#include <type_traits>
#include <vector>

G_BEGIN_DECLS

  typedef struct _TestingRefCountMonitor TestingRefCountMonitor;

  GType testing_ref_count_monitor_get_type (void) G_GNUC_CONST;

  static inline TestingRefCountMonitor* testing_ref_count_monitor_new (gboolean* destroyed)
    {

      return (TestingRefCountMonitor*) g_object_new (testing_ref_count_monitor_get_type (),
        "destroyed", destroyed,
        NULL);
    }

  static inline TestingRefCountMonitor* testing_ref_count_monitor_ref (TestingRefCountMonitor* monitor)
    {
      return g_object_ref (monitor);
    }

  static inline void testing_ref_count_monitor_unref (TestingRefCountMonitor* monitor)
    {
      return g_object_unref (monitor);
    }

G_END_DECLS

namespace testing
{

  namespace details
    {

      template<typename T>
      concept __g_test_add_function_c = std::is_default_constructible_v<T>;

      template<typename T>
      concept __g_test_add_function_d = std::is_destructible_v<T>;

      template<typename T>
      concept __g_test_add_function_cd = __g_test_add_function_c<T>
                                      && __g_test_add_function_d<T>;

      template<typename T, typename... Args>
      concept __g_test_add_function_fn = std::is_invocable_r_v<void, T, Args...>;
    }

  void g_test_add_function (const char* path, std::function<void()>&& func);

  template<details::__g_test_add_function_fn Fn>
  static inline void g_test_add_ (const char* path, Fn&& action)
    {
      g_test_add_function (path, std::function<void ()> (std::move (action)));
    }

  template<details::__g_test_add_function_cd T,
           details::__g_test_add_function_fn<const T&> Fn>
  static inline void g_test_add_ (const char* path, Fn&& action)
    {

      auto func = [action = std::forward<Fn> (action)]
                  { auto fixture = T (); action (fixture); };
      g_test_add_function (path, std::function<void ()> (std::move (func)));
    }

  template<details::__g_test_add_function_d T,
           details::__g_test_add_function_fn<const T&> Fn>
  static inline void g_test_add_ (const char* path, Fn&& action, std::function<T ()>&& setup)
    {

      auto func = [action = std::forward<Fn> (action), setup = std::move (setup)]
                  { auto fixture = setup (); action (fixture); };
      g_test_add_function (path, std::function<void ()> (std::move (func)));
    }

  template<typename T,
           details::__g_test_add_function_fn<const T&> Fn>
  static inline void g_test_add_ (const char* path, Fn&& action, std::function<T ()>&& setup, std::function<void (T&&)>&& destroy)
    {

      auto func = [action = std::forward<Fn> (action), destroy = std::move (destroy), setup = std::move (setup)]
                  { auto fixture = setup (); action (fixture); destroy (std::move (fixture)); };
      g_test_add_function (path, std::function<void ()> (std::move (func)));
    }

  gchar* g_test_analyze_times (const std::vector<gdouble>& times) noexcept;

  class dtor_tester
    {

      bool _flag = false;
    public:

      class able
        {

          bool& _flag;
        public:
          inline able (bool& flag) noexcept: _flag (flag) { }
          inline ~able () { _flag = true; }
        };

      inline constexpr bool get_dtor_ed () const noexcept { return _flag; };

      inline able make_tester () { return able (_flag); }
      inline able* new_tester () { return new able (_flag); }
    };

  #define g_assert_cmp(s1,cmp,s2) (G_GNUC_EXTENSION ({ \
 ; \
      const auto& __s1 = ((s1)); \
      const auto& __s2 = ((s2)); \
 ; \
      if (false == (__s1 cmp __s2)) \
        g_assertion_message (G_LOG_DOMAIN, __FILE__, __LINE__, G_STRFUNC, #s1 " " #cmp " " #s2); \
    }))

  #define g_assert_cmpstring(s1,cmp,s2) (G_GNUC_EXTENSION ({ \
 ; \
      const auto __s1 = std::string ( ((s1)) ); \
      const auto __s2 = std::string ( ((s2)) ); \
 ; \
      if (false == (__s1 cmp __s2)) \
        g_assertion_message_cmpstr (G_LOG_DOMAIN, __FILE__, __LINE__, G_STRFUNC, \
          #s1 " " #cmp " " #s2, __s1.c_str (), #cmp, __s2.c_str ()); \
    }))

  static inline void g_assert_destructed (const char* domain, const char* file, int line, const char* func, const char* expr, dtor_tester tester) noexcept
    {

      if (! tester.get_dtor_ed ())
        {

          auto m = std::string (expr) + " was not destructed";

          g_assertion_message (domain, file, line, func, m.c_str ());
          g_assert_not_reached ();
        }
    }

  #define g_assert_destructed(tester) (G_GNUC_EXTENSION ({ \
 ; \
      (g_assert_destructed) (G_LOG_DOMAIN, __FILE__, __LINE__, G_STRFUNC, #tester, ((tester))); \
    }))

  template<typename Ex,
           typename Fn,
           typename E = std::enable_if_t<std::is_invocable_v<Fn>>>
  static inline Ex g_assert_throw (const char* domain, const char* file, int line, const char* func, const char* expr, Fn&& action) noexcept
    {

      try { action (); } catch (Ex& e)
        { return e; }

      auto m = std::string (expr) + " should throw";
      g_assertion_message (domain, file, line, func, m.c_str ());
      g_assert_not_reached ();
    }

  #define g_assert_throw(type,expr) (G_GNUC_EXTENSION ({ \
 ; \
      (g_assert_throw< type >) (G_LOG_DOMAIN, __FILE__, __LINE__, G_STRFUNC, #expr, [&]() { expr; }); \
    }))

  template<typename Fn, typename E = std::enable_if_t<std::is_invocable_v<Fn>>>
  static inline void g_assert_no_throw (const char* domain, const char* file, int line, const char* func, const char* expr, Fn&& action) noexcept
    {

      try { action (); } catch (std::exception& e)
        {
          auto m = std::string (expr) + " should not throw. Got " + e.what ();
          g_assertion_message (domain, file, line, func, m.c_str ());
        }
    }

  #define g_assert_no_throw(expr) (G_GNUC_EXTENSION ({ \
 ; \
      (g_assert_no_throw) (G_LOG_DOMAIN, __FILE__, __LINE__, G_STRFUNC, #expr, [&]() { expr; }); \
    }))

  template<typename T,
           typename = std::enable_if_t<std::is_default_constructible_v<T>>>
  static inline std::vector<T> g_test_rand_array (size_t max = 20, size_t min = 0) noexcept (std::is_nothrow_default_constructible_v<T>)
    {
      auto count = g_test_rand_int_range (min, 1 + max);
    return std::vector<T> (count);
    }

  template<typename T>
  static inline std::vector<T> g_test_rand_array (std::function<T()>&& rand, size_t max = 20, size_t min = 0)
    {
      auto array = std::vector<T> ();
      auto count = g_test_rand_int_range (min, 1 + max);

      array.reserve (count);

      for (glib_typeof (count) i = 0; i < count; ++i) array.push_back (rand ());
    return array;
    }

  #define g_test_rand_bool() (1 == g_test_rand_int_range (0, 2))

  void g_test_rand_data (guint8* data, size_t size);
  std::pair<guint8*, gsize> g_test_rand_data (size_t max = 200, size_t min = 1) noexcept;

  static inline GBytes* g_test_rand_bytes (size_t max = 200, size_t min = 1) noexcept
    {
      auto [ data, size ] = g_test_rand_data (max, min);
      return g_bytes_new_take (data, size);
    }

  template<typename T, typename... Ts>
  static inline T g_test_rand_diff (std::function<T()>&& rand, const Ts&... prev) noexcept
    {

      while (true) if (auto next = rand (); ((next != prev) && ...))
        return next;

      static_assert ((std::is_same_v<T, std::remove_cvref_t<Ts>> && ...), "All arguments must be T");
    }

  std::string g_test_rand_string (size_t max = 20, size_t min = 1, const char* charset = nullptr) noexcept;

  template<typename... Ts>
  static inline std::string g_test_rand_string (size_t max = 20, size_t min = 0, const char* charset = nullptr, const Ts&... prev) noexcept
    {

      while (true) if (auto next = g_test_rand_string (max, min, charset); ((next != prev) && ...))
        return next;

      static_assert ((std::is_same_v<std::string, std::remove_cvref_t<Ts>> && ...), "All arguments must be std::string");
    }

  template<typename T> static inline const T& g_test_rand_pick (const T* ar, size_t length) noexcept
    {
      return ar [g_test_rand_int_range (0, length)];
    }

  template<typename T, int Sz> static inline const T& g_test_rand_pick (const std::array<T, Sz>& ar) noexcept
    {
      return g_test_rand_pick (ar.data (), Sz);
    }

  template<typename T> static inline const T& g_test_rand_pick (const std::vector<T>& ar) noexcept
    {
      return g_test_rand_pick (ar.data (), ar.size ());
    }

  static inline gint64 g_test_rand_int64 () noexcept
    {

      union { guint8 data; gint64 value; } u;
    return (g_test_rand_data (&u.data, sizeof (u)), u.value);
    }

  static inline guint32 g_test_rand_uint32 () noexcept
    {

      union { guint8 data; guint32 value; } u;
    return (g_test_rand_data (&u.data, sizeof (u)), u.value);
    }

  static inline guint64 g_test_rand_uint64 () noexcept
    {

      union { guint8 data; guint64 value; } u;
    return (g_test_rand_data (&u.data, sizeof (u)), u.value);
    }

  namespace details
    {

      template<typename T>
      struct __basic_generator { typedef T (*func) (); };

      template<typename T, __basic_generator<T>::func gen> static inline constexpr T __range_rejection (T min, T max, T range, T limit) noexcept
        G_GNUC_PURE;

      template<typename T, __basic_generator<T>::func gen> static inline constexpr T __range_rejection (T min, T max, T range, T limit) noexcept
        {

          T result; do
            { result = gen (); }
          while (result >= limit);

        return min + (result % range);
        }
    }

  static inline gint64 g_test_rand_int64_range (gint64 min, gint64 max) noexcept
    {

      g_return_val_if_fail (max >= min, min);

      if (min == max)
        return min;

      else
        { gint64 range = max - min + 1;
          gint64 limit = G_MAXUINT64 / range * range;
          return details::__range_rejection<gint64, g_test_rand_int64> (min, max, range, limit); }
    }

  static inline gint64 g_test_rand_uint64_range (guint64 min, guint64 max) noexcept
    {

      g_return_val_if_fail (max >= min, min);

      if (min == max)
        return min;

      else
        { guint64 range = max - min + 1;
          guint64 limit = G_MAXUINT64 / range * range;
          return details::__range_rejection<guint64, g_test_rand_uint64> (min, max, range, limit); }
    }

  GVariant* g_test_rand_variant (const GVariantType* vtype, int max_depth = 7, int max_width = 10) noexcept;
  GVariantType* g_test_rand_variant_type (const char* possible, ssize_t n_possible, int max_depth = 7, int max_width = 10) noexcept;

  static inline GVariant* g_test_rand_variant (const char* possible, ssize_t n_possible, int max_depth = 7, int max_width = 10) noexcept
    {

      auto vtype = g_test_rand_variant_type (possible, n_possible, max_depth, max_width);
      auto value = g_test_rand_variant (vtype, max_depth, max_width);

    return (g_variant_type_free (vtype), value);      
    }

  gchar* g_read_offsource (const gchar* name, gsize* out_length = nullptr);
  gchar* g_str_indent_up (const gchar* value, guint by = 1);
}