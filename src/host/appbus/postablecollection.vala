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

  public class PostableCollection: GLib.Object, ICollection<IPostable>
    {

      struct Entry
        {

          public uint post_id;
          public IPostable postable;

          public Entry (IPostable postable)
            {
              this.post_id = 0;
              this.postable = postable;
            }
        }

      public size_t length { get { return _ar.length; } }

      private GLib.Array<Entry> _ar = new Array<Entry> (false, false);
      private bool _touched = false;

      public void add (owned IPostable postable)
        {

          _ar.append_val (Entry (postable));
          _touched = true;
        }

      public void del (IPostable postable)
        {

          uint post_id;

          if (try_del (postable, out post_id) && 0 != post_id)
            warning ("removing a posted object from the collection");
        }

      public CollectionIter<IPostable> iterator ()
        {

          assert_not_reached ();
        }

      public bool try_del (IPostable postable, out uint post_id = null)
        {

          bool _result;

          _result = del_impl (_ar, postable, _touched, out post_id);
          _touched = false;
        return _result;
        }

      [CCode (cheader_filename = "host/appbus/postablecollection.h")]
      static extern bool del_impl (Array<Entry> ar, IPostable postable, bool touched, out uint post_id);

      public bool post (GLib.DBusConnection connection, string object_path) throws GLib.Error
        {

          bool r; try
            {
              r = post_ (connection, object_path);
              return r;
            }
          catch (GLib.Error error)
            {
              unpost (connection, object_path);
              throw (owned) error;
            }
        }

      private bool post_ (GLib.DBusConnection connection, string object_path) throws GLib.Error
        {

          unowned Entry* data = _ar.data;

          for (size_t i = 0; i < _ar.length; ++i)
            data [i].post_id = data [i].postable.post (connection, object_path);
        return true;
        }

      public void unpost (GLib.DBusConnection connection, string object_path)
        {

          unowned Entry* data = _ar.data;
          unowned uint registration_id;

          for (size_t i = 0; i < _ar.length; ++i) if (0 != (registration_id = data [i].post_id))
            connection.unregister_object (registration_id);
        }
    }
}