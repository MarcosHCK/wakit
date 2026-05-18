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

  public class ExtensionHost: GLib.Object, IExtensionDataHost, IExtensionHost
    {

      public ICollection<string> accessible_uri_outsource { get; }
      public ICollection<string> accessible_uri_whitelist { get; }
      public string bus_address { get; set; }
      public string? bus_cookie { get; set; }
      public WebKit.WebContext context { get; construct; }
      public GLib.Variant? extension_data { get; set; }
      public string? extension_dir { get; set; }
      public ICollection<string> secure_schemes { get; }

      public ExtensionHost (WebKit.WebContext context)
        {
          Object (context: context);
        }

      public override void constructed ()
        {

          base.constructed ();
          _context.initialize_web_process_extensions.connect (on_initialize_web_process_extensions);

          _accessible_uri_outsource = new PtrArrayCollection<string> ();
          _accessible_uri_whitelist = new PtrArrayCollection<string> ();
          _secure_schemes = new PtrArrayCollection<string> ();
        }

      private void on_initialize_web_process_extensions ()
        {

          GLib.Variant @params = serialize (GLib.Uuid.string_random ());

          if (null != _extension_dir)
          _context.set_web_process_extensions_directory (_extension_dir);
          _context.set_web_process_extensions_initialization_user_data (@params);
        }
    }
}