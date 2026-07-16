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

  public sealed class PtrArrayCollection<T>: GLib.Object, ICollection<T>
    {

      public size_t length { get { return _struct.length; } }

      public GenericArray<T> @struct { get { return _struct; } }
      private GenericArray<T> _struct = new GenericArray<T> ();

      sealed class CollectionIterImpl<T>: CollectionIter<T>
        {

          private GenericArray<T> _array;
          private size_t _iter;

          public CollectionIterImpl (GenericArray<T> _struct)
            {
              _array = _struct;
              _iter = 0;
            }

          public override bool next (out unowned T item)
            {

              size_t i = _iter;

              if (i < _array.length) { item = _array.data [i];
                                       return true; }
              item = null;
            return false;
            }
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

      public override (unowned T)[] to_array ()
        {

          var count = _struct.length;
          var array = new (unowned T) [count];

          unowned var data = _struct.data;

          for (size_t i = 0; i < count; ++i)
            array [i] = data [i];
        return array;
        }
    }
}