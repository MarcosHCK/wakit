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

  public sealed class ListCollection<T>: GLib.Object, ICollection<T>
    {

      public size_t length { get { return (size_t) _struct.length; } }

      public GLib.List<T> @struct { get { return _struct; } }
      private GLib.List<T> _struct = new GLib.List<T> ();

      sealed class CollectionIterImpl<T>: CollectionIter<T>
        {

          private unowned GLib.List<T> _iter;

          public CollectionIterImpl (GLib.List<T> _struct)
            {
              _iter = _struct;
            }

          public override bool next (out unowned T item)
            {

              if (null != _iter) {  item = _iter.data;
                                   _iter = _iter.next;
                                   return true; }
              item = null;
            return false;
            }
        }

      public void add (owned T value)
        {
          _struct.append ((owned) value);
        }

      public void del (T value)
        {
          _struct.remove (value);
        }

      public CollectionIter<T> iterator ()
        {

        return new CollectionIterImpl<T> (_struct);
        }
    }
}