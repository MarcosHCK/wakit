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
#include <common/wakit-common.h>
#include <cstring>
#include <extension/resource.h>

GBytes* wakit_lookup_build_script (GResource* resource, const gchar* path)
{

  static const char suffix [] = "\n__module__";

  auto bytes = wakit_lookup_build_resource (resource, path);

  auto size = (gsize) 0;
  auto data = (guint8*) g_bytes_get_data (bytes, &size);

  auto result = (guint8*) g_malloc (size + G_N_ELEMENTS (suffix) - 1);

  memcpy (result, data, size);
  memcpy (result + size, suffix, G_N_ELEMENTS (suffix) - 1);

return g_bytes_new_take (result, size + G_N_ELEMENTS (suffix) - 1);
}