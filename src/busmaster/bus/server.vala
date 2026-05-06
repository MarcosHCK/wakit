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

  public sealed class Server: GLib.Object
    {

      public string guid { get; set; }

      private GLib.HashTable<string, Client> _clients;
      private GLib.HashTable<string, Name> _names;
      private uint32 _next_major_id = 0;
      private uint32 _next_minor_id = 0;

      ~Server ()
        {
          print ("~Server ()\n");
        }

      public Server (string guid)
        {
          Object (guid: guid);
        }

      public bool add_client (GLib.DBusConnection connection)
        {

          connection.exit_on_close = false;

          string id = ":%u.%u".printf (_next_major_id, _next_minor_id);

          if (_next_minor_id < uint32.MAX)

            { ++_next_minor_id; }
          else
            { ++_next_major_id; _next_minor_id = 0; }

          Client client; try
            {
              _clients.insert (id, client = new Client (connection, id, this));
            }
          catch (GLib.Error error)
            {
              GLib.warning ("Server.add_client ()!: %s: %u: %s",
                error.domain.to_string (), error.code, error.message);
              return false;
            }

          client.add_filter (filter);
          client.disconnected.connect (on_client_disconnected);
          connection.start_message_processing ();

          broadcast_name_owner_changed (id, null, id);
        return true;
        }

      private void broadcast (Client? not_to, GLib.DBusMessage message, bool has_destination, bool preserve_serial)
        {

          unowned Client client;

          for (var iter = GLib.HashTableIter<string, Client> (_clients); iter.next (null, out client);)

            if (client != not_to)

          foreach (unowned var match in client.matches) if (match.matches (message, has_destination))
            {

              var flags = preserve_serial == false ? 0 : GLib.DBusSendMessageFlags.PRESERVE_SERIAL;

              try
                { client.connection.send_message (message.copy (), flags, null); }

              catch (GLib.Error error)
                {
                  unowned uint code = error.code;
                  unowned string domain = error.domain.to_string ();
                  unowned string message_ = error.message.to_string ();

                  GLib.warning ("Server.broadcast ()!: %s: %u: %s", domain, code, message_);
                }
              break;
            }
        }

      private void broadcast_name_owner_changed (string name, string? old_name, string? new_name)
        {

          const string interface_ = IBus.NAME;
          const string path = IBus.PATH;
          const string signal_ = "NameOwnerChanged";

          GLib.DBusMessage message;

          GLib.Variant items [] = { new GLib.Variant.string (name),
                                    new GLib.Variant.string (old_name ?? ""),
                                    new GLib.Variant.string (new_name ?? ""), };

          GLib.Variant body = new GLib.Variant.tuple (items);

          (message = new GLib.DBusMessage.signal (path, interface_, signal_)).set_body (body);
          broadcast (null, message, false, false);
        }

      public override void constructed ()
        {

          base.constructed ();
          unowned GLib.HashFunc<string> hash_func = GLib.str_hash;
          unowned GLib.EqualFunc<string> key_equal_func = GLib.str_equal;

          _clients = new GLib.HashTable<string, Client> (hash_func, key_equal_func);
          _names = new GLib.HashTable<string, Name> (hash_func, key_equal_func);
        }

      public GLib.DBusMessage? ensure_unlocked (owned GLib.DBusMessage message)
        {

          try
            {
             return message.locked ? message.copy () : (owned) message;
            }
          catch (GLib.Error error)
            {
              unowned uint code = error.code;
              unowned string domain = error.domain.to_string ();
              unowned string message_ = error.message.to_string ();

              GLib.warning ("Server.filter ()!: %s: %u: %s", domain, code, message_);
            }
        return null;
        }

      private GLib.DBusMessage? filter (Client client, owned GLib.DBusMessage message, bool incoming)
        {

          if (incoming)
            {

              if (null == (message = ensure_unlocked ((owned) message)))
                return null;

              message.set_sender (client.id);
            }
          else if (message.get_destination () == null || message.get_sender () == null)
            {

              if (null == (message = ensure_unlocked ((owned) message)))
                return null;

              if (message.get_destination () == null)
                message.set_destination (client.id);

              if (message.get_sender () == null)
                message.set_sender (IBus.NAME);
            }
        return !incoming ? message : route (client, (owned) message);
        }

      internal string[] list_names ()
        {

          unowned var size = _clients.size () + _names.size () + 1;
          unowned var value = (string) null;

          var ar = new GenericArray<string> (size);

          ar.add (IBus.NAME);

          for (var iter = GLib.HashTableIter<string, Client> (_clients); iter.next (out value, null);)
            ar.add (value);

          for (var iter = GLib.HashTableIter<string, Name> (_names); iter.next (out value, null);)
            ar.add (value);

        return ar.steal ();
        }

      internal unowned Client? lookup_client (string id)
        {

          unowned Client value;
          unowned bool found = _clients.lookup_extended (id, null, out value);

        return !found ? null : value;
        }

      internal unowned Name? lookup_name (string name)
        {

          unowned Name value;
          unowned bool found = _names.lookup_extended (name, null, out value);

        return !found ? null : value;
        }

      private void on_client_disconnected (Client client, bool remote_peer_vanished, GLib.Error? error)
        {

          _clients.remove (client.id);
        }

      public void reap_all ()
        {

          unowned Client client;

          for (var iter = GLib.HashTableIter<string, Client> (_clients); iter.next (null, out client);)
            {
              client.disconnected.disconnect (on_client_disconnected);
              client.reap ();
            }

          _clients.remove_all ();
        }

      private GLib.DBusMessage? route (Client client, owned GLib.DBusMessage message)
        {

          unowned var destination = (string?) null;
          unowned var destination_client = (Client?) null;
          unowned var name = (Name?) null;

          if (null != (destination = message.get_destination ()) && IBus.NAME != destination)
            {

              if (null == (destination_client = _clients.get (destination)))
                {

                  if (null != (name = _names.get (destination)) && null != name.owner)
                    destination_client = name.owner.client;
                }

              if (null == destination_client && GLib.DBusMessageType.METHOD_CALL == message.get_message_type ())
                {
                  GLib.Error error = new GLib.DBusError.SERVICE_UNKNOWN ("The name %s is unknown", destination);
                  return route_error (client, message, (owned) error);
                }
              else if (null != destination_client) try
                {
                  destination_client.connection.send_message (message, GLib.DBusSendMessageFlags.PRESERVE_SERIAL, null);
                }
              catch (GLib.Error error)
                {
                  unowned uint code = error.code;
                  unowned string domain = error.domain.to_string ();
                  unowned string message_ = error.message.to_string ();
                  
                  GLib.critical ("Server.route ()!: %s: %u: %s", domain, code, message_);
                }
            }

          broadcast (client, message, destination_client != null, true);

        return destination == null || destination != IBus.NAME ? null : message;
        }

      private GLib.DBusMessage? route_error (Client client, GLib.DBusMessage invoke, owned GLib.Error error)
        {

          var error_ger = new GLib.Error (error.domain, error.code, "");
          var error_name = GLib.DBusError.encode_gerror (error_ger);

          unowned var error_message = error.message;
          unowned var flags = GLib.DBusSendMessageFlags.NONE;
          unowned var method_call_message = invoke;

          var message = new GLib.DBusMessage.method_error_literal (method_call_message, error_name, error_message);

          try
            { client.connection.send_message (message, flags, null); }
          catch (GLib.Error e)
            {
              unowned uint code = error.code;
              unowned string domain = error.domain.to_string ();
              unowned string message_ = error.message.to_string ();
              
              GLib.critical ("Server.route_error ()!: %s: %u: %s", domain, code, message_);
            }
        return null;
        }
    }
}
