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

  public sealed class AuthenticationServer: GLib.Object
    {

      private Krypt.CookieAuth.Server _auth_server;

      public AuthenticationServer (Cookie cookie)
        {

          Object ();
          _auth_server = new Krypt.CookieAuth.Server (cookie.to_string (), "dbus-authentication");
        }

      public async bool authenticate (GLib.IOStream stream, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          var _istream = stream.get_input_stream ();
          var _ostream = stream.get_output_stream ();

          Krypt.CookieAuth.Challenge challenge = _auth_server.next_challenge ();
          yield challenge.write (_ostream, GLib.Priority.DEFAULT, cancellable);

          Krypt.CookieAuth.Response response = new Krypt.CookieAuth.Response ();
          yield response.read (_istream, GLib.Priority.DEFAULT, cancellable);

          if (! _auth_server.check_challenge (challenge, response))
            throw new GLib.DBusError.AUTH_FAILED ("invalid authentication cookie");

          yield _ostream.write_all_async (FINE, GLib.Priority.DEFAULT, cancellable, null);

        return true;
        }
    }

  public static async GLib.DBusConnection connect_server (GLib.IOStream stream, string guid, AuthenticationServer? auth_server, uint timeout = 0, GLib.Cancellable? cancellable = null) throws GLib.Error
    {

      var _cancellable = new TimeoutCancellable (timeout, cancellable);

      if (null != auth_server)
        yield auth_server.authenticate (stream, _cancellable);

      const GLib.DBusConnectionFlags flag1 = GLib.DBusConnectionFlags.AUTHENTICATION_SERVER;
      const GLib.DBusConnectionFlags flag2 = GLib.DBusConnectionFlags.DELAY_MESSAGE_PROCESSING;
      const GLib.DBusConnectionFlags flags = flag1 | flag2;

      var connection = yield new GLib.DBusConnection (stream, guid, flags, null, _cancellable);

      connection.exit_on_close = false;
    return connection;
    }
}