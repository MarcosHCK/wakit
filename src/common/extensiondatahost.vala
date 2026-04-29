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

      internal const string SIGNATURE = "("
        + _V_TYPE_STRING
        + _V_TYPE_STRING
        + _V_TYPE_ANY
        + _V_TYPE_STRING_ARRAY
        + _V_TYPE_STRING_ARRAY
        + _V_TYPE_STRING_ARRAY
        + ")";

      internal const string _V_TYPE_ANY = "*";
      internal const string _V_TYPE_ARRAY = "a";
      internal const string _V_TYPE_STRING = "s";
      internal const string _V_TYPE_STRING_ARRAY = _V_TYPE_ARRAY + "s";

      public abstract ICollection<string> accessible_uri_outsource { get; }
      public abstract ICollection<string> accessible_uri_whitelist { get; }
      public abstract string bus_address { get; set; }
      public abstract GLib.Variant? extension_data { get; set; }
      public abstract ICollection<string> secure_schemes { get; }

      public virtual GLib.Variant serialize (string guid)
          requires (bus_address != null)
          ensures (result.check_format_string (IExtensionDataHost.SIGNATURE, false))
        {

          GLib.Variant items [] =
            {

              new GLib.Variant.string (bus_address),
              new GLib.Variant.string (guid),
              extension_data ?? new GLib.Variant.boolean (false),
              new GLib.Variant.strv (accessible_uri_outsource.to_array ()),
              new GLib.Variant.strv (accessible_uri_whitelist.to_array ()),
              new GLib.Variant.strv (secure_schemes.to_array ()),
            };

        return new GLib.Variant.tuple (items);
        }
    }
}