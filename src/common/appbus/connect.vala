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

  public static async GLib.DBusConnection connect_client (string address, GLib.Bytes? cookie = null, GLib.Cancellable? cancellable = null) throws GLib.Error
    {

      const GLib.DBusConnectionFlags flag1 = GLib.DBusConnectionFlags.AUTHENTICATION_CLIENT;
      const GLib.DBusConnectionFlags flag2 = GLib.DBusConnectionFlags.MESSAGE_BUS_CONNECTION;
      const GLib.DBusConnectionFlags flags = flag1 | flag2;

      var connection = yield new GLib.DBusConnection.for_address (address, flags, null, cancellable);

      connection.exit_on_close = false;
    return connection;
    }

  public static async GLib.DBusConnection connect_server (GLib.IOStream stream, string guid, GLib.Bytes? cookie = null, GLib.Cancellable? cancellable = null) throws GLib.Error
    {

      const GLib.DBusConnectionFlags flag1 = GLib.DBusConnectionFlags.AUTHENTICATION_SERVER;
      const GLib.DBusConnectionFlags flag2 = GLib.DBusConnectionFlags.DELAY_MESSAGE_PROCESSING;
      const GLib.DBusConnectionFlags flags = flag1 | flag2;

      var connection = yield new GLib.DBusConnection (stream, guid, flags, null, cancellable);

      connection.exit_on_close = false;
    return connection;
    }
}