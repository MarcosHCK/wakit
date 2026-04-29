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

  public interface IExtensionDataGuest: GLib.Object
    {

      public abstract string bus_address { get; protected set; }
      public abstract GLib.Variant? extension_data { get; protected set; }
      public abstract string guid { get; protected set; }
      public abstract ICollection<string> secure_schemes { get; }

      public virtual bool deserialize (GLib.Variant variant)
          requires (variant != null)
          requires (variant.check_format_string (IExtensionDataHost.SIGNATURE, false))
        {

          unowned string str;
          GLib.Variant var_;
          GLib.VariantIter_ iter;

          variant.get_child (0, "&s", out str);
          guid = str;

          variant.get_child (1, "&s", out str);
          bus_address = str;

          extension_data = variant.get_child_value (3);

          ICollection<string> secure_schemes = this.secure_schemes;

          for (iter = GLib.VariantIter_ (var_ = variant.get_child_value (2)); iter.next ("&s", out str);)
            secure_schemes.add (str.dup ());

        return true;
        }
    }
}