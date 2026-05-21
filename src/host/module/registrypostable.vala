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

namespace Wakit.Host.Module
{

  [DBus (name = "org.hck.wakit.Host.Module.Registry")]
  public sealed class RegistryPostable: GLib.Object, IPostable
    {

      [DBus (visible = false)]
      public Registry? registry { set; }

      [DBus (name = "list_names")] public async string[] list_names () throws GLib.Error
        {

          if (unlikely (null == _registry))
            return { };

          var array = new string [_registry.watchers.length];
          for (int i = 0; i < _registry.watchers.length; ++i) array [i] = _registry.watchers [i].bus_name;

        return array;
        }

      [DBus (visible = false)] public uint post (GLib.DBusConnection connection, string object_path) throws GLib.Error
        {

        return connection.register_object (object_path, this);
        }
    }
}