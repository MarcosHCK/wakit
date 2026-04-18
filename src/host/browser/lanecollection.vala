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

namespace Wakit.Browser
{

  internal sealed class LaneCollection: GLib.Object, ICollection<ExtensionLane>
    {

      private GenericArray<ExtensionLane> items { get; }
      private bool _touched = false;

      public void add (owned ExtensionLane lane)
        {

          _items.add ((owned) lane);
          _touched = true;
        }

      public override void constructed ()
        {

          base.constructed ();
          _items = new GenericArray<ExtensionLane?> ();
        }

      public void del (ExtensionLane lane)
        {

          _items.remove (lane);
        }

      public GLib.Variant serialize ()
        {

        return serialize_impl (_items);
        }

      [CCode (cheader_filename = "host/browser/lanecollection.h",
              returns_floating_reference = true)]
      static extern GLib.Variant serialize_impl (GenericArray<ExtensionLane> items);
    }
}