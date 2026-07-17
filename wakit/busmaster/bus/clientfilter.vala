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

namespace Wakit.Busmaster.Bus
{

  internal sealed class ClientFilter
    {

      private unowned Client _client;
      private FilterFunction _filter_function;
      private uint _filter_id;

      ~ClientFilter ()
        {
          debug ("~ClientFilter ()\n");
        }

      public ClientFilter (Client client, owned FilterFunction filter_function)
        {

          _client = client;
          _filter_function = (owned) filter_function;
          _filter_id = _g_dbus_connection_add_filter (client.connection, filter);
        }

      private GLib.DBusMessage? filter (GLib.DBusConnection connection, owned GLib.DBusMessage message, bool incoming)
        {

        return _filter_function (_client, (owned) message, incoming);
        }

      [CCode (cheader_filename = "gio/gio.h",
              cname = "g_dbus_connection_add_filter")]
      extern static uint _g_dbus_connection_add_filter (GLib.DBusConnection connection,
                                                        GLib.DBusMessageFilterFunction filter_function,
                                                        GLib.DestroyNotify? notify = null);

      [CCode (cheader_filename = "gio/gio.h", instance_pos = 3.9)]
      public delegate GLib.DBusMessage? FilterFunction (Client client, owned GLib.DBusMessage message, bool incoming);
    }
}