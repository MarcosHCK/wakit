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

namespace Wakit.Simple.Configuration
{

  [CCode (cheader_filename = "glib.h,common/json/wakit-common-json.h",
          cname = "GPtrArray",
          type_id = "(wakit_json_generic_ptr_array_get_type (G_TYPE_STRING))"),
   Compact (opaque = true)]
  public class StringArray: GenericArray<string> { }
}