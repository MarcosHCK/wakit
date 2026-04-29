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

  public sealed class GenericSetCollection<T>: GLib.Object, ICollection<T>
    {

      public size_t length { get { return _struct.length; } }

      public GenericSet<T> @struct { get { return _struct; }
                            construct { _struct = value; } }
      private GenericSet<T> _struct;

      sealed class CollectionIterImpl<T>: CollectionIter<T>
        {

          private GenericSetIter<T> _iter;

          public CollectionIterImpl (GenericSet<T> _struct)
            {
              _iter = _struct.iterator ();
            }

          public override bool next (out unowned T item)
            {

              unowned T? value = _iter.next_value ();
                          item = value;
            return null != value;
            }
        }

      public GenericSetCollection (GLib.HashFunc<T> hash_func, GLib.EqualFunc<T> equal_func)
        {

          Object (@struct: new GenericSet<T> (hash_func, equal_func));
        }

      public void add (owned T value)
        {
          _struct.add ((owned) value);
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