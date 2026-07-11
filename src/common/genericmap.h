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
#include <common/boxing.h>
#include <common/soo.h>
#include <cstring>
#include <glib-object.h>
#include <type_traits>

namespace generic_map
{

  template<size_t _nargs> requires (_nargs > 0)
  class generic_map;
}

template<size_t _nargs> requires (_nargs > 0)
class generic_map::generic_map
{
public:

  struct key_type
    {

      GType arguments [_nargs];

      inline constexpr const GType* data () const noexcept
        {
        return arguments;
        }

      inline constexpr bool operator== (const key_type& o) const noexcept
        {
          constexpr auto size = sizeof (arguments[0]) * _nargs;
        return 0 == memcmp (arguments, o.arguments, size);
        }
    };

  typedef GType value_type;

private:
  GRWLock _lock;

  static gboolean _equal_func (gconstpointer p_key_a, gconstpointer p_key_b) noexcept
    {

      auto& key_a = *soo_ptr::cast<key_type> (&p_key_a);
      auto& key_b = *soo_ptr::cast<key_type> (&p_key_b);
    return key_a == key_b;
    }

  static guint _hash_func (gconstpointer p_key) noexcept
    {

      auto& key = *soo_ptr::cast<key_type> (&p_key);

      constexpr guint FNV_OFFSET_BASIS = 2166136261u;
      constexpr guint FNV_PRIME = 16777619u;
      constexpr guint element_size = sizeof (key_type[0]);

      auto data = (const guint8*) key.data ();
      auto hash = FNV_OFFSET_BASIS;

      for (std::remove_cvref_t<decltype (_nargs)> i = 0; i < _nargs * element_size; ++i)
        {
          hash ^= data [i];
          hash *= FNV_PRIME;
        }
    return hash;
    }

  static void _notify_func (gpointer key) noexcept
    {

      soo_ptr::destroy<key_type> (&key);
    }

  struct initialize_func_helper
    {
    private:

    template<typename = std::make_index_sequence<_nargs>>
    struct helper;
    
    template<size_t... Is>
    struct helper<std::index_sequence<Is...>>
      {
        using type = GType (*) (decltype ((void) Is, GType {}) ...) noexcept;
      };
        
    public:
      using type = typename helper<>::type;
    };

  [[gnu::always_inline]]
  static inline GString* append_type_name (GString* string, GType type) noexcept
    {

      auto name = g_type_name (type);
    return g_string_append (string, name);
    }

  template<typename... Args>
  [[gnu::always_inline]]
  static inline GString* append_type_names (GString* string, GType first, Args... rest) noexcept
    {

      if constexpr (sizeof... (Args) == 0)

        return (append_type_name (string, first), string);
      else
        return (append_type_name (string, first), append_type_names (g_string_append_c (string, '-'), rest ...));
    }

  boxing::destructible_box<GHashTable, g_hash_table_unref> _table;
public:

  typedef typename initialize_func_helper::type InitializeFunc;

  inline generic_map () noexcept:
      _table (g_hash_table_new_full (_hash_func, _equal_func, _notify_func, NULL))
    {
      g_rw_lock_init (&_lock);
    }

  template<typename... Args>
    requires (sizeof... (Args) == _nargs && (std::same_as<Args, GType> &&...))
  static const gchar* build_name (const gchar* prefix, Args... types) noexcept
    {

      auto builder = g_string_new (prefix);

      g_string_append_c (builder, '+');
      append_type_names (builder, types ...);
      g_string_append_c (builder, '+');

      auto name = g_intern_string (builder->str);

      g_string_free (builder, FALSE);
    return name;
    }

  template<typename... Args>
    requires (sizeof... (Args) == _nargs && (std::same_as<Args, GType> &&...))
  inline GType ensure_type (InitializeFunc init_func, Args... types) noexcept
    {

      key_type args { types ... };
      gpointer result { };

      if (g_rw_lock_reader_lock (&_lock); FALSE == g_hash_table_lookup_extended (*_table, &args, NULL, &result))

        g_rw_lock_reader_unlock (&_lock);
      else
        return (g_rw_lock_reader_unlock (&_lock), GPOINTER_TO_TYPE (result));

      if (g_rw_lock_writer_lock (&_lock); TRUE == g_hash_table_lookup_extended (*_table, &args, NULL, &result))
        return GPOINTER_TO_TYPE (result);

      auto g_type = init_func (types ...);
      auto key = (void*) NULL;

      g_hash_table_insert (*_table, (soo_ptr::create<key_type> (&key, args), key), result = GTYPE_TO_POINTER (g_type));

    return (g_rw_lock_writer_unlock (&_lock), g_type);
    }
};