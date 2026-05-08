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

  static async void authenticate_client (GLib.IOStream stream, Cookie cookie, GLib.Cancellable? cancellable = null) throws GLib.Error
    {

      var _cookie = "%s\n".printf (cookie.to_string ());
      var _istream = stream.get_input_stream ();
      var _ostream = stream.get_output_stream ();

      uint8 answer [5];
      size_t bytes;

      /* F**k vala */
      assert (answer.length == FINE.length);

      yield _ostream.write_all_async (_cookie.data, GLib.Priority.DEFAULT, cancellable, out bytes);
      yield _istream.read_all_async (answer, GLib.Priority.DEFAULT, cancellable, out bytes);

      if (unlikely (0 != GLib.Memory.cmp (answer, FINE, answer.length)))
        throw new GLib.DBusError.AUTH_FAILED ("server refused connection");
    }

  public static async GLib.DBusConnection connect_client (string address, uint timeout = 0, Cookie? cookie = null, GLib.Cancellable? cancellable = null) throws GLib.Error
    {

      string? guid = null;
      GLib.IOStream stream = yield GLib.DBus.address_get_stream (address, cancellable, out guid);

      var _cancellable = new TimeoutCancellable (timeout, cancellable);

      if (null != cookie)
        yield authenticate_client (stream, cookie, _cancellable);

      guid = null;

      const GLib.DBusConnectionFlags flag1 = GLib.DBusConnectionFlags.AUTHENTICATION_CLIENT;
      const GLib.DBusConnectionFlags flag2 = GLib.DBusConnectionFlags.MESSAGE_BUS_CONNECTION;
      const GLib.DBusConnectionFlags flags = flag1 | flag2;

      var connection = yield new GLib.DBusConnection (stream, guid, flags, null, _cancellable);

      connection.exit_on_close = false;
    return connection;
    }
}