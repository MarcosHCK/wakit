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

namespace Wakit
{

  internal struct PostableEntry
    {

      public uint post_id;
      public IPostable postable;

      public PostableEntry (IPostable postable)
        {
          this.post_id = 0;
          this.postable = postable;
        }
    }

  [Compact (opaque = true)] internal class PostableRegistry: GLib.Array<PostableEntry>
    {

      public PostableRegistry ()
        {
          base (false, false, sizeof (PostableEntry));
        }

      public void add (IPostable postable)
        {

          append_val (PostableEntry (postable));
        }

      public bool post (GLib.DBusConnection connection, string object_path) throws GLib.Error
        {

          unowned PostableEntry* data = this.data; try
            {
              for (size_t i = 0; i < length; ++i)
                data [i].post_id = data [i].postable.post (connection, object_path);
            }
          catch (GLib.Error error)
            {
              unpost (connection, object_path);
              throw (owned) error;
            }
        return true;
        }

      public void unpost (GLib.DBusConnection connection, string object_path)
        {

          unowned PostableEntry* data = this.data;
          unowned uint post_id;

          for (size_t i = 0; i < length; ++i) if (0 != (post_id = data [i].post_id))
            connection.unregister_object (post_id);
        }
    }
}