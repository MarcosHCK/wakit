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
#include <common/ffi/function.h>
#include <common/ffi/destroynotify.h>
#include <unordered_map>

std::unordered_map<GType, ffi::function<void, gpointer>> _functions;

[[gnu::always_inline]]
static inline const ffi::function<void, gpointer>& ensure_boxed (GType g_type) noexcept
{

  if (auto iter = _functions.find (g_type); iter != _functions.end ())

    return iter->second;
  else
    return _functions.emplace (g_type, [=](gpointer boxed) -> void { g_boxed_free (g_type, boxed); }).first->second;
}

GDestroyNotify wakit_ffi_destroy_notify_for_boxed (GType g_type)
{

return ensure_boxed (g_type).get_codeloc ();
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
static inline const ffi::function<void, gpointer>& ensure_valued (GType g_type, GTypeValueTable* table) noexcept
{

  if (auto iter = _functions.find (g_type); iter != _functions.end ())

    return iter->second;
  else
    return _functions.emplace (g_type, [=](gpointer instance) -> void { free_using_value_table (g_type, table, instance); }).first->second;
}

GDestroyNotify wakit_ffi_destroy_notify_using_value_table (GType g_type, GTypeValueTable* table)
{

return ensure_valued (g_type, table).get_codeloc ();
}