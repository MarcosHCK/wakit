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

      public abstract ICollection<GLib.Regex> accessible_uri_outsource { get; }
      public abstract ICollection<GLib.Regex> accessible_uri_whitelist { get; }
      public abstract string bus_address { get; protected set; }
      public abstract string? bus_cookie { get; protected set; }
      public abstract GLib.Variant? extension_data { get; protected set; }
      public abstract string guid { get; protected set; }
      public abstract ICollection<string> secure_schemes { get; }

      public virtual bool deserialize (GLib.Variant variant)
          requires (variant != null)
          requires (variant.check_format_string (IExtensionDataHost.SIGNATURE, false))
        {

          try
            { return deserialize_ (variant); }
          catch (GLib.Error error)
            { GLib.error ("Wakit.IExtensionDataGuest.deserialize ()!: %s: %u: %s",
                error.domain.to_string (), error.code, error.message); }
        }

      private bool deserialize_ (GLib.Variant variant) throws GLib.Error
        {

          int c = 0;
          unowned string? str;
          GLib.Variant var_;
          GLib.VariantIter_ iter;

          variant.get_child (c++, "&s", out str);
          bus_address = str;

          variant.get_child (c++, "m&s", out str);
          bus_cookie = str;

          variant.get_child (c++, "&s", out str);
          guid = str;

          extension_data = variant.get_child_value (c++);

          ICollection<GLib.Regex> accessible_uri_outsource = this.accessible_uri_outsource;
          ICollection<GLib.Regex> accessible_uri_whitelist = this.accessible_uri_whitelist;
          ICollection<string> secure_schemes = this.secure_schemes;

          unowned GLib.RegexCompileFlags compile_option1 = GLib.RegexCompileFlags.OPTIMIZE;
          unowned GLib.RegexCompileFlags compile_options = compile_option1;

          for (iter = GLib.VariantIter_ (var_ = variant.get_child_value (c++)); iter.next ("&s", out str);)
            accessible_uri_outsource.add (new GLib.Regex (str, compile_options));

          for (iter = GLib.VariantIter_ (var_ = variant.get_child_value (c++)); iter.next ("&s", out str);)
            accessible_uri_whitelist.add (new GLib.Regex (str, compile_options));

          for (iter = GLib.VariantIter_ (var_ = variant.get_child_value (c++)); iter.next ("&s", out str);)
            secure_schemes.add (str.dup ());

        return true;
        }
    }
}