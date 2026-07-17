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
      public GLib.SList<Match> matches { get { return _matches; } }

      public Server? server { owned get { return (Server) _server.get (); }
                            private set { _server.set (value); } }

      public signal void disconnected (bool remove_peer_vanished, GLib.Error? error);

      private ClientFilter? _client_filter = null;
      private GLib.SList<Match> _matches = new GLib.SList<Match> ();
      private uint _registration_id = 0;
      private GLib.WeakRef _server = GLib.WeakRef (null);

      ~Client ()
        {
          debug ("~Client () <id = %s>\n", _id);
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

      public async void add_match (string rule) throws GLib.Error
        {

          Match match;

          if (null != (match = Match.parse (rule)))

            _matches.prepend (match);
          else
            throw new GLib.DBusError.MATCH_RULE_INVALID ("Invalid rule: %s", rule);
        }

      public async uint8[] get_connection_selinux_security_context (string name) throws GLib.Error
        {
          throw new GLib.DBusError.SELINUX_SECURITY_CONTEXT_UNKNOWN ("selinux context not supported");
        }

      public async uint get_connection_unix_process_id (string name) throws GLib.Error
        {
          throw new GLib.DBusError.UNIX_PROCESS_ID_UNKNOWN ("connection pid not supported");
        }

      public async uint get_connection_unix_user (string name) throws GLib.Error
        {
          throw new GLib.DBusError.UNIX_PROCESS_ID_UNKNOWN ("connection user not supported");
        }

      public async string get_id () throws GLib.Error
        {

          string id;

          if (null != (id = server?.guid))

            return (owned) id;
          else
            throw new GLib.DBusError.FAILED ("headless client");
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

      public async string[] list_queued_owners (string name) throws GLib.Error
        {

          unowned Name? _name;

          if (null == (_name = server?.lookup_name (name)))
            return {};

          var ar = new GenericArray<string> (_name.queue_length);

          foreach (unowned var queuedOwner in _name.queue)
            ar.add (queuedOwner.client.id);

        return ar.steal ();
        }

      public async bool name_has_owner (string name) throws GLib.Error
        {

          if (':' == name [0])

            return null != server?.lookup_client (name);
          else
            { unowned Name? _name = server?.lookup_name (name);
              return null != _name && null != _name.owner; }
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

      public async uint release_name (string name) throws GLib.Error
        {

          unowned Name _name;
          Server? server;

          if (null == (server = this.server))
            throw new GLib.DBusError.FAILED ("headless client");

          Name.check_name (name);

          if (null == (_name = server.lookup_name (name)))
            return ReleaseNameReply.NON_EXISTENT;

          else if (null != _name.owner || this == _name.owner?.client)
            { _name.release_owner (server);
              return ReleaseNameReply.RELEASED; }

          else if (_name.unqueue_owner (this, server))

            return ReleaseNameReply.RELEASED;
          else
            return ReleaseNameReply.NOT_OWNER;
        }

      public async void reload_config () throws GLib.Error
        {
        }

      public async void remove_match (string rule) throws GLib.Error
        {

          Match match;

          if (null != (match = Match.parse (rule)))

            { unowned GLib.SList<Match> link_; if (null != (link_ = _matches.find_custom (match, Match.compare)))
                _matches.delete_link (link_); }
          else
            throw new GLib.DBusError.MATCH_RULE_INVALID ("Invalid rule: %s", rule);
        }

      public async uint request_name (string name, uint _flags) throws GLib.Error
        {

          unowned NameFlags flags = (NameFlags) _flags;
          unowned Name _name;
          unowned RequestNameReply result;

          Server? server;

          if (null == (server = this.server))
            throw new GLib.DBusError.FAILED ("headless client");

          Name.check_name (name);

          if ((_name = server.ensure_name (name)).owner == null)
            { _name.replace_owner (server, new NameOwner (this, flags));
              result = RequestNameReply.PRIMARY_OWNER; }

          else if (_name.owner != null && _name.owner.client == this)
            { _name.owner.flags = flags;
              result = RequestNameReply.ALREADY_OWNER; }

          else if (( NameFlags.DO_NOT_QUEUE in flags) && (NameFlags.REPLACE_EXISTING in flags) || (NameFlags.ALLOW_REPLACEMENT in flags))
            { _name.unqueue_owner (this, server);
              result = RequestNameReply.EXISTS; }

          else if (!(NameFlags.DO_NOT_QUEUE in flags) && (!(NameFlags.REPLACE_EXISTING in flags) || !(NameFlags.ALLOW_REPLACEMENT in _name.owner.flags)))
            { _name.queue_owner (new NameOwner (this, flags));
              result = RequestNameReply.IN_QUEUE; }

          else
            { _name.replace_owner (server, new NameOwner (this, flags));
              result = RequestNameReply.PRIMARY_OWNER; }

        return result;
        }

      public async uint start_service_by_name (string name, uint flags) throws GLib.Error
        {

          if (null != server?.lookup_name (name))

            return StartServiceReply.ALREADY_RUNNING;
          else
            throw new GLib.DBusError.SERVICE_UNKNOWN ("No support for activation for name: %s", name);
        }

      public async void update_activation_environment (HashTable<string, string> environment) throws GLib.Error
        {
          throw new GLib.DBusError.FAILED ("UpdateActivationEnvironment not implemented");
        }
    }
}