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

  public class Bus: GLib.Object
    {

      public string bus_name { get; construct; }
      public PostableCollection postables { get; private set; }

      private string _object_path;
      private uint _own_id;

      public Bus (string bus_name)
        {
          Object (bus_name: bus_name);
        }

      static string build_path (string bus_name)
        {

          int length = bus_name.length;
          var builder = new StringBuilder.sized (2 + length);

          builder.append_len ("/", 1);
          builder.append_len (bus_name, length);
          builder.replace (".", "/");
        return builder.free_and_steal ();
        }

      public override void constructed ()
        {

          base.constructed ();

          _postables = new PostableCollection ();
          _object_path = build_path (_bus_name);
        }

      public async bool graft_on_connection (GLib.DBusConnection connection, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          unowned var flag1 = GLib.BusNameOwnerFlags.DO_NOT_QUEUE;
          unowned var flags = flag1;

          _own_id = yield own_name_async (connection, _bus_name, flags, cancellable);
          postables.post (connection, _object_path);
        return true;
        }

      public void reap_on_connection (GLib.DBusConnection connection)
        {

          postables.unpost (connection, _object_path);
          GLib.Bus.unown_name (_own_id);
        }
    }
}