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

  internal sealed class Name
    {

      public string name { get; private set; }
      public NameOwner? owner { get; private owned set; }
      public GLib.List<NameOwner> queue { get { return _queue.head; } }
      public uint queue_length { get { return _queue.length; } }
      private GLib.Queue<NameOwner> _queue;

      ~Name ()
        {
          debug ("~Name () <name = %s>\n", _name);
        }

      public Name (string name)
        {

          _name = name;
          _owner = null;
          _queue = new GLib.Queue<NameOwner> ();
        }

      public static void check_name (string name) throws GLib.DBusError
        {

          if (GLib.DBus.is_name (name) == false)
            throw new GLib.DBusError.INVALID_ARGS ("Requested bus name \"%s\" is not valid", name);

          else if (name [0] == ':')
            throw new GLib.DBusError.INVALID_ARGS ("Cannot acquire a service starting with ':' such as \"%s\"", name);

          else if (name == IBus.NAME)
            throw new GLib.DBusError.INVALID_ARGS ("Cannot acquire a service named " + IBus.NAME + ", because that is reserved");
        }

      public void queue_owner (owned NameOwner owner)
        {

          foreach (unowned var other in queue) if (owner.client == other.client)
            return;

          _queue.push_tail ((owned) owner);
        }

      public void release_owner (Server server)
        {

          NameOwner? next = null;

          next = _queue.pop_head ();
          owner.flags |= NameFlags.DO_NOT_QUEUE;

          replace_owner (server, (owned) next);
        }

      public void replace_owner (Server server, owned NameOwner? new_owner = null)
        {

          unowned var new_client = new_owner == null ? null : new_owner.client;
          unowned var new_name = (string?) null;
          unowned var old_owner = owner;
          unowned var old_client = old_owner == null ? null : old_owner.client;
          unowned var old_name = (string?) null;

          if (null != old_owner)
            {

              assert (old_client != new_client);

              old_name = old_client.id;
              old_client.name_lost (name);

              if (! (NameFlags.DO_NOT_QUEUE in old_owner.flags))
                _queue.push_head ((owned) owner);
            }

          if (null != (owner = (owned) new_owner))
            {

              unqueue_owner (owner.client, server);

              new_name = new_client.id;
              new_client.name_acquired (name);
            }

          server.broadcast_name_owner_changed (name, old_name, new_name);
          server.claim_name (this);
        }

      public bool unqueue_owner (Client client, Server server)
        {

          bool found = false;

          for (unowned GLib.List<NameOwner> link = _queue.head; null != link; link = link.next) if (client == link.data.client)
            {

              found = true;
              _queue.delete_link (link);
              break;
            }

          server.claim_name (this);
        return found;
        }
    }
}