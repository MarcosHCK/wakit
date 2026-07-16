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

namespace Wakit.AppBus
{

  [CCode (has_copy_function = false, has_type_id = false)] public struct AddressString
    {

      public unowned string value;
      public uint length;

      public AddressString (string value, uint length = value.length)
        {

          this.length = length;
          this.value = value;
        }

      public string get_value ()
        {
          return ndup (value, length);
        }

      [CCode (cname = "g_strndup")]
      extern static string ndup (string value, size_t length);
    }
}