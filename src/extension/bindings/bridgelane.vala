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

namespace Wakit.Binding
{

  [Compact (opaque = true)] public class BridgeLane
    {

      public string interface_name { get; private set; }
      public string object_path { get; private set; }
      public string property_name { get; private set; }
      public string type_name { get; private set; }

      static string guess_property_name (string type_name)
        {

        return type_name.ascii_down ();
        }

      static string guess_type_name (string interface_name)
        {

          var pieces = interface_name.split (".");
          var last = pieces [pieces.length - 1];
        return last;
        }

      public BridgeLane (string interface_name, string object_path, string? property_name = null, string? type_name = null)
        {

          _interface_name = interface_name;
          _object_path = object_path;
          _type_name = type_name ?? guess_type_name (interface_name);
          _property_name = property_name ?? guess_property_name (_type_name);
        }
    }
}