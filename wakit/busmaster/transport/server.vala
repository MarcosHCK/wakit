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

namespace Wakit.Busmaster.Transport
{

  public sealed class Server: GLib.Object, GLib.AsyncInitable
    {

      public bool active { get; default = false; }
      public string address { get; construct; }
      public GLib.SocketService socket_listener { get; }

      private GLib.Cancellable? _server_cancellable = null;
      private ulong _signal_handler = 0;
      private string? _unix_path = null;

      public signal bool incoming (GLib.IOStream connection);

      public Server (string address)
        {
          Object (address: address);
        }

      public async Server.async (string address,
                                 int io_priority = GLib.Priority.DEFAULT, GLib.Cancellable? cancellable = null) throws GLib.Error
        {
          Object (address: address);
          yield init_async (io_priority, cancellable);
        }

      public override async bool init_async (int io_priority = GLib.Priority.DEFAULT, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          var address = new AppBus.Address.from_string (_address);
          var result = false;

          _socket_listener = new GLib.SocketService ();

          switch (address.transport)
            {

            case "tcp": result = yield init_tcp_async (address, io_priority, cancellable);
              break;

            case "unix": result = yield init_unix_async (address, io_priority, cancellable);
              break;

            default: throw new GLib.IOError.INVALID_ARGUMENT (_ ("invalid address transport '%s'"), address.transport);
            }
        return result;
        }

      static char next_ascii ()
        {

          int c = GLib.Random.int_range (0, 60);
          int a = c < 25 ? c + 'A' : (c < 50 ? c + 'a' - 25 : c + '0' - 50);
        return (char) a;
        }

      static string next_unix_address (string dir)
        {

          unowned var dir_len = dir.length;
          unowned var prefix = "/dbus-";
          unowned var prefix_len = prefix.length;
          unowned var suffix_len = 8;

          var builder = new StringBuilder.sized (dir.length + prefix_len + suffix_len);

          builder.append_len (dir, dir_len);
          builder.append_len (prefix, prefix_len);

          for (int i = 0; i < suffix_len; ++i)
            builder.append_c (next_ascii ());

        return builder.free_and_steal ();
        }

      private bool on_incoming (GLib.SocketConnection connection, GLib.Object? source_object)
        {

          incoming (connection);
        return true;
        }

      public void start ()
        {

          if (true == _active)
            return;

          _server_cancellable = new GLib.Cancellable ();
          _signal_handler = _socket_listener.incoming.connect (on_incoming);
          _socket_listener.start ();

          _active = true;
          notify_property ("active");
        }

      public void stop ()
        {

          if (false == _active)
            return;

          _server_cancellable.cancel ();

          _socket_listener.disconnect (_signal_handler);
          _socket_listener.stop ();

          _active = false;
          notify_property ("active");

          if (null != _unix_path && 0 != GLib.FileUtils.unlink (_unix_path))
            {
              unowned string message = GLib.strerror (errno);
              GLib.warning ("Wakit.Busmaster.Transport.Server.unlink_unix ()!: %s", message);
            }

          _unix_path = null;
        }

      private bool try_add_address (GLib.SocketAddress socket_address, out GLib.SocketAddress effective_address = null) throws GLib.Error
        {

          unowned GLib.SocketType type = GLib.SocketType.STREAM;
          unowned GLib.SocketProtocol protocol = GLib.SocketProtocol.DEFAULT;
          unowned GLib.Object? source_object = null;

        return _socket_listener.add_address (socket_address, type, protocol, source_object, out effective_address);
        }

      private async bool init_tcp_async (AppBus.Address address, int io_priority = GLib.Priority.DEFAULT, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          unowned AppBus.AddressOption? option1 = null;

          string? host = null;
          uint16 port = 0;

          if (null != (option1 = address.lookup_option ("host")))
            host = option1.value;

          if (null != (option1 = address.lookup_option ("port")))
            {

              uint64 integer;
              uint64.from_string (option1.value, out integer, 10, uint16.MIN, uint16.MAX);
              port = (uint16) integer;
            }

          var resolver = GLib.Resolver.get_default ();

          foreach (unowned var inet_address in yield resolver.lookup_by_name_async (host, cancellable))
            {

              GLib.SocketAddress socket_address = new GLib.InetSocketAddress (inet_address, port),
                                 effective_address = null;

              try_add_address (socket_address, out effective_address);

              if (0 == port)
                port = ((GLib.InetSocketAddress) effective_address).get_port ();
            }

          _address = "tcp:host=%s,port=%u".printf (host, port);
        return true;
        }

      private async bool init_unix_async (AppBus.Address address, int io_priority = GLib.Priority.DEFAULT, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          GLib.UnixSocketAddress? socket_address = null;
          unowned AppBus.AddressOption? option1 = null;
          unowned AppBus.AddressOption? option2 = null;

          if (null != (option1 = address.lookup_option ("path")))
            {

              try_add_address (new GLib.UnixSocketAddress (option1.value));
            }
          else if (null != (option1 = address.lookup_option ("dir")) ||
                   null != (option2 = address.lookup_option ("tmpdir"))) {
          for (string dir = null == option2 ? option1.value : option2.value; true;)
            {

              string sock_file = next_unix_address (dir);

              socket_address = new GLib.UnixSocketAddress (sock_file);

              try
                { try_add_address (socket_address); break; }
              catch (GLib.IOError.ADDRESS_IN_USE error)
                {  }
            } }
          else if (null != (option1 = address.lookup_option ("abstract")))
            {

              if (! GLib.UnixSocketAddress.abstract_names_supported ())
                throw new GLib.IOError.NOT_SUPPORTED (_ ("abstract namespace not supported"));

              unowned string path = option1._value.value;
              unowned int length = (int) option1._value.length;
              unowned GLib.UnixSocketAddressType type = GLib.UnixSocketAddressType.ABSTRACT;

              try_add_address (new GLib.UnixSocketAddress.with_type (path, length, type));
            }

          if (unlikely (null == socket_address))
            throw new GLib.IOError.INVALID_ARGUMENT (_ ("bad unix socket address"));

          string address_path = socket_address.get_path ();
          string escaped_path = GLib.DBus.address_escape_value (address_path);

          switch (socket_address.get_address_type ())
            {

            case GLib.UnixSocketAddressType.ABSTRACT: _address = "unix:abstract=%s".printf (escaped_path);
              break;

            case GLib.UnixSocketAddressType.PATH: _address = "unix:path=%s".printf (escaped_path);
                                                  _unix_path = escaped_path;
              break;

            default: assert_not_reached ();
            }
        return true;
        }
    }
}