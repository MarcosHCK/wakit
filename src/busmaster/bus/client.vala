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

  internal sealed class Client: GLib.Object, IBus
    {

      public GLib.DBusConnection connection { get; private set; }
      public string id { get; private set; }
      public GLib.List<Match> matches { get { return _matches; } }

      public Server? server { owned get { return (Server) _server.get (); }
                            private set { _server.set (value); } }

      public signal void disconnected (bool remove_peer_vanished, GLib.Error? error);

      private ClientFilter? _client_filter = null;
      private GLib.List<Match> _matches = new GLib.List<Match> ();
      private uint _registration_id = 0;
      private GLib.WeakRef _server = GLib.WeakRef (null);

      ~Client ()
        {
          print ("~Client () <id = %s>\n", _id);
        }

      public Client (GLib.DBusConnection connection, string id, Server server) throws GLib.Error
        {

          _connection = connection;
          _id = id;
          _registration_id = connection.register_object<IBus> (IBus.PATH, this);
          _server.set (server);

          connection.on_closed.connect (on_connection_closed);
        }

      [CCode (cheader_filename = "gio/gio.h", instance_pos = 3.9)]
      public delegate GLib.DBusMessage? FilterFunction (Client client, owned GLib.DBusMessage message, bool incoming);

      public void add_filter (owned FilterFunction filter_function)
          requires (null == _client_filter)
        {
          _client_filter = new ClientFilter (this, (owned) filter_function);
        }

      public async string get_name_owner (string name) throws GLib.Error
        {

          if (name == IBus.NAME)
            return name;

          unowned Client? client;
          unowned Name? name_;

          if (name [0] == ':' && null != (client = server?.lookup_client (name)))
            return name;
   
          else if (null != (name_ = server?.lookup_name (name)))
            return name_.owner.client._id;

          throw new GLib.DBusError.NAME_HAS_NO_OWNER ("Could not get owner of name '%s': no such name", name);
        }

      public async string hello () throws GLib.Error
        {

          name_acquired (id);
        return id;
        }

      public async string[] list_activatable_names () throws GLib.Error
        {

        return {};
        }

      public async string[] list_names () throws GLib.Error
        {

          string[]? ar;

          if (null != (ar = server?.list_names ()))

            return (owned) ar;
          else
            throw new GLib.DBusError.FAILED ("headless client");
        }

      private void on_connection_closed (bool remove_peer_vanished, GLib.Error? error)
        {

          reap ();
          disconnected (remove_peer_vanished, error);
        }

      public void reap ()
        {

          connection.unregister_object (_registration_id);
          connection.close.begin ();
        }

      public async uint start_service_by_name (string name, uint flags) throws GLib.Error
        {

          if (null != server?.lookup_name (name))

            return StartServiceReply.ALREADY_RUNNING;
          else
            throw new GLib.DBusError.SERVICE_UNKNOWN ("No support for activation for name: %s", name);
        }
    }
}