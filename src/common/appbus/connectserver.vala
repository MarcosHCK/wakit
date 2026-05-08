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

  const uint8 FINE [] = { 'F', 'I', 'N', 'E', '\n' };

  static async void authenticate_server (GLib.IOStream stream, Cookie cookie, GLib.Cancellable? cancellable = null) throws GLib.Error
    {

      var _cookie = cookie.to_string ();
      var _istream = stream.get_input_stream ();
      var _ostream = stream.get_output_stream ();

      var buffer = new uint8 [_cookie.length + 1];
      size_t bytes;

      yield _istream.read_all_async (buffer, GLib.Priority.DEFAULT, cancellable, out bytes);

      if (0 != GLib.Memory.cmp (buffer, _cookie.data, buffer.length - 1) || '\n' != buffer [buffer.length - 1])
        throw new GLib.DBusError.AUTH_FAILED ("invalid authentication cookie");

      yield _ostream.write_all_async (FINE, GLib.Priority.DEFAULT, cancellable, out bytes);
    }

  public static async GLib.DBusConnection connect_server (GLib.IOStream stream, string guid, uint timeout = 0, Cookie? cookie = null, GLib.Cancellable? cancellable = null) throws GLib.Error
    {

      var _cancellable = new TimeoutCancellable (timeout, cancellable);

      if (null != cookie)
        yield authenticate_server (stream, cookie, _cancellable);

      const GLib.DBusConnectionFlags flag1 = GLib.DBusConnectionFlags.AUTHENTICATION_SERVER;
      const GLib.DBusConnectionFlags flag2 = GLib.DBusConnectionFlags.DELAY_MESSAGE_PROCESSING;
      const GLib.DBusConnectionFlags flags = flag1 | flag2;

      var connection = yield new GLib.DBusConnection (stream, guid, flags, null, _cancellable);

      connection.exit_on_close = false;
    return connection;
    }
}