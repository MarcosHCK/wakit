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

namespace Wakit
{

  [CCode (cname = "WakitBusMaster",
          lower_case_cprefix = "wakit_bus_master_")]
  public interface IBusMaster: GLib.Application
    {

      public virtual bool acquire (string bus_address, GLib.DBusConnection connection) throws GLib.Error
        {
          return default_acquire (bus_address, connection);
        }

      public bool default_acquire (string bus_address, GLib.DBusConnection connection) throws GLib.Error
        {

          var path = (string) build_path (application_id);
          var good = (bool) dbus_register (connection, path);
        return good;
        }

      public void default_release (string bus_address, GLib.DBusConnection connection)
        {

          var path = (string) build_path (application_id);
          dbus_unregister (connection, path);
        }

      private static string build_path (string application_id)
        {

          var length = application_id.length;
          var builder = new StringBuilder.sized (2 + length);

          builder.append_len ("/", 1);
          builder.append_len (application_id, length);
          builder.replace (".", "/");

        return builder.free_and_steal ();
        }

      public virtual void release (string bus_address, GLib.DBusConnection connection)
        {
          default_release (bus_address, connection);
        }
    }
}