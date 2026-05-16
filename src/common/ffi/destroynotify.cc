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
#include <common/boxing.h>
#include <common/ffi/destroynotify.h>
#include <common/ffi/function.h>
#include <common/slice.h>

static inline GHashTable* _make_functions ()
{

  constexpr GEqualFunc equal_func = g_direct_equal;
  constexpr GHashFunc hash_func = g_direct_hash;
  constexpr GDestroyNotify notify = g_slice_free_<ffi::function<void, gpointer>>;

return g_hash_table_new_full (hash_func, equal_func, NULL, notify);
}

boxing::destructible_box<GHashTable, g_hash_table_unref> _functions (_make_functions ());

[[gnu::always_inline]]
static inline ffi::function<void, gpointer>* make_boxed (GType g_type) noexcept
{

return g_slice_new_<ffi::function<void, gpointer>> ([=](gpointer boxed) -> void
  { g_boxed_free (g_type, boxed); });
}

[[gnu::always_inline]]
static inline const ffi::function<void, gpointer>& ensure_boxed (GType g_type) noexcept
{

  ffi::function<void, gpointer>* actual;
  gpointer key = GTYPE_TO_POINTER (g_type);

  if (g_hash_table_lookup_extended (*_functions, key, NULL, (gpointer*) &actual))

    return *actual;
  else
    return (g_hash_table_insert (*_functions, key, actual = make_boxed (g_type)), *actual);
}

GDestroyNotify wakit_ffi_destroy_notify_for_boxed (GType g_type)
{

return ensure_boxed (g_type).get_codeloc ();
}

template<size_t N>
static constexpr std::array<GType, N> _make_primitive_table (const GType (&entries) [N])
{

  std::array<GType, N> ar;
  std::copy (entries, &entries [N], ar.begin ());
  std::sort (ar.begin (), ar.end ());
return ar;
}

static constexpr GType _primitive_entries [] = {
  G_TYPE_BOOLEAN,
  G_TYPE_CHAR, G_TYPE_UCHAR,
  G_TYPE_INT, G_TYPE_UINT,
  G_TYPE_LONG, G_TYPE_ULONG,
  G_TYPE_INT64, G_TYPE_UINT64,
  G_TYPE_ENUM, G_TYPE_FLAGS,
  G_TYPE_FLOAT, G_TYPE_DOUBLE,
};

static constexpr auto _primitive_table = _make_primitive_table (_primitive_entries);

gboolean wakit_ffi_destroy_notify_type_is_primitive (GType g_type)
{

  auto iter = std::lower_bound (_primitive_table.begin (), _primitive_table.end (), g_type);
return iter != _primitive_table.end () && *iter == g_type;
}

[[gnu::always_inline]]
static inline void free_using_value_table (GType g_type, GTypeValueTable* table, gpointer instance)
{

  auto value = GValue G_VALUE_INIT;

  g_value_init (&value, g_type);
  value.data [0].v_pointer = instance;
  g_value_unset (&value);
}

[[gnu::always_inline]]
static inline ffi::function<void, gpointer>* make_valued (GType g_type, GTypeValueTable* table) noexcept
{

return g_slice_new_<ffi::function<void, gpointer>> ([=](gpointer instance) -> void
  { free_using_value_table (g_type, table, instance); });
}

[[gnu::always_inline]]
static inline const ffi::function<void, gpointer>& ensure_valued (GType g_type, GTypeValueTable* table) noexcept
{

  ffi::function<void, gpointer>* actual;
  gpointer key = GTYPE_TO_POINTER (g_type);

  if (g_hash_table_lookup_extended (*_functions, key, NULL, (gpointer*) &actual))

    return *actual;
  else
    return (g_hash_table_insert (*_functions, key, actual = make_valued (g_type, table)), *actual);
}

GDestroyNotify wakit_ffi_destroy_notify_using_value_table (GType g_type, GTypeValueTable* table)
{

return ensure_valued (g_type, table).get_codeloc ();
}