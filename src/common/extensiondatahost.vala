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

  public interface IExtensionDataHost: GLib.Object
    {

      public const string SIGNATURE = "(ssas*)";

      public abstract string bus_address { get; set; }
      public abstract GLib.Variant? extension_data { get; set; }
      public abstract ICollection<string> secure_schemes { get; }

      public virtual GLib.Variant serialize (string guid)
          requires (bus_address != null)
        {

          GLib.Variant items [] =
            {

              new GLib.Variant.string (guid),
              new GLib.Variant.string (bus_address),
              new GLib.Variant.strv (secure_schemes.to_array ()),
              extension_data ?? new GLib.Variant.boolean (false),
            };

        return new GLib.Variant.tuple (items);
        }
    }
}