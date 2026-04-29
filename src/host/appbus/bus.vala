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

  public class Bus: GLib.Object, IAppBus
    {

      public ICollection<IPostable> postables { get { return _postables; } }

      private uint _own_id;
      private PostableCollection _postables;

      public override void constructed ()
        {

          base.constructed ();

          _postables = new PostableCollection ();
        }

      public async bool graft_on_connection (GLib.DBusConnection connection, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          unowned var flag1 = GLib.BusNameOwnerFlags.DO_NOT_QUEUE;
          unowned var flags = flag1;

          _own_id = yield own_name_async (connection, IAppBus.BUS_NAME, flags, cancellable);
          _postables.post (connection, GLib.Path.build_filename (IAppBus.BUS_OBJECT_PATH, "services"));
        return true;
        }

      public void reap_on_connection (GLib.DBusConnection connection)
        {

          _postables.unpost (connection, GLib.Path.build_filename (IAppBus.BUS_OBJECT_PATH, "services"));
          GLib.Bus.unown_name (_own_id);
        }
    }
}