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

  public interface ICollection<T>: GLib.Object
    {

      public abstract size_t length { get; }

      public abstract void add (owned T value);
      public abstract void del (T value);
      public abstract CollectionIter<T> iterator ();

      public virtual (unowned T)[] to_array ()
        {

          var array = new (unowned T) [length];
          var next = (size_t) 0;

          foreach (unowned T item in this)
            array [next++] = item;
        return array;
        }
    }
}