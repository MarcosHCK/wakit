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

  public sealed class AuthenticationClient: GLib.Object
    {

      private Krypt.CookieAuth.Client _auth_client;

      public AuthenticationClient (Cookie cookie)
        {

          Object ();
          _auth_client = new Krypt.CookieAuth.Client (cookie.to_string (), "dbus-authentication");
        }

      public async bool authenticate (GLib.IOStream stream, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          var _istream = stream.get_input_stream ();
          var _ostream = stream.get_output_stream ();

          Krypt.CookieAuth.Challenge challenge = new Krypt.CookieAuth.Challenge ();
          yield challenge.read (_istream, GLib.Priority.DEFAULT, cancellable);

          Krypt.CookieAuth.Response response = _auth_client.respond_challenge (challenge);
          yield response.write (_ostream, GLib.Priority.DEFAULT, cancellable);

          uint8 answer [5];
          /* F**k vala */
          assert (answer.length == FINE.length);

          yield _istream.read_all_async (answer, GLib.Priority.DEFAULT, cancellable, null);

          if (unlikely (0 != GLib.Memory.cmp (answer, FINE, answer.length)))
            throw new GLib.DBusError.AUTH_FAILED ("server refused connection");

        return true;
        }
    }

  static Cookie? extract_cookie (string address) throws GLib.Error
    {

      var _address = new Address.from_string (address);
      var _option = (AddressOption?) null;

    return null == (_option = _address.lookup_option ("x-cookie"))
                 ? null : new Cookie.from_string (_option._value.value, _option._value.length);
    }

  public async GLib.DBusConnection connect_client (string address, uint timeout = 0, GLib.Cancellable? cancellable = null) throws GLib.Error
    {

      Cookie? cookie = extract_cookie (address);

      string? guid = null;
      GLib.IOStream stream = yield GLib.DBus.address_get_stream (address, cancellable, out guid);

      var _cancellable = new TimeoutCancellable (timeout, cancellable);

      if (null != cookie)
        {

          var auth_client = new AuthenticationClient (cookie);
          yield auth_client.authenticate (stream, _cancellable);
        }

      guid = null;

      const GLib.DBusConnectionFlags flag1 = GLib.DBusConnectionFlags.AUTHENTICATION_CLIENT;
      const GLib.DBusConnectionFlags flag2 = GLib.DBusConnectionFlags.MESSAGE_BUS_CONNECTION;
      const GLib.DBusConnectionFlags flags = flag1 | flag2;

      var connection = yield new GLib.DBusConnection (stream, guid, flags, null, _cancellable);

      connection.exit_on_close = false;
    return connection;
    }
}