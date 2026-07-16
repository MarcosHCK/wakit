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
#include <wakit/common/boxing.h>
#include <wakit/host/module/module.h>

boxing::destructible_box<GHashTable, g_hash_table_unref> _table;

GHashTable* wakit_host_module_imodule_get_loader_mapping (void)
{

  static GHashTable* __static_ref = nullptr;

  if (g_once_init_enter (&__static_ref))
    {

      _table = wakit_host_module_imodule_get_loader_mapping_once ();
      g_once_init_leave (&__static_ref, *_table);
    }
return __static_ref;
}