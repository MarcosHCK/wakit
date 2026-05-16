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
#include <common/boxing.h>
#include <common/slice.h>
#include <glib-object.h>

namespace generic_map
{

  template<size_t _nargs> requires (_nargs > 0)
  class generic_map;
}

template<size_t _nargs> requires (_nargs > 0)
class generic_map::generic_map
{
public:

  typedef typename std::array<GType, _nargs> key_type;
  typedef GType value_type;

private:
  G_LOCK_DEFINE (lock);

  static gboolean _equal_func (gconstpointer p_key_a, gconstpointer p_key_b) noexcept
    {

      auto& key_a = *(key_type*) p_key_a;
      auto& key_b = *(key_type*) p_key_b;
    return key_a == key_b;
    }

  static guint _hash_func (gconstpointer p_key) noexcept
    {

      auto& key = *(key_type*) p_key;

      constexpr guint FNV_OFFSET_BASIS = 2166136261u;
      constexpr guint FNV_PRIME = 16777619u;
      constexpr guint element_size = sizeof (typename key_type::value_type);

      auto data = (guint8*) key.data ();
      auto hash = FNV_OFFSET_BASIS;

      for (decltype (key.size ()) i = 0; i < _nargs * element_size; ++i)
        {
          hash ^= data [i];
          hash *= FNV_PRIME;
        }
    return hash;
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
      G_LOCK_NAME (lock) { },
      _table (g_hash_table_new_full (_hash_func, _equal_func, g_slice_free_<key_type>, NULL))
    { }

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

      G_LOCK (lock);

      std::array<GType, _nargs> args { types ... };
      gpointer result { };

      if (! g_hash_table_lookup_extended (*_table, &args, NULL, &result))
        {
          auto g_type = init_func (types ...);
          g_hash_table_insert (*_table, g_slice_new_<key_type> (args), result = GTYPE_TO_POINTER (g_type));
        }
    return (G_UNLOCK (lock), GPOINTER_TO_TYPE (result));
    }
};