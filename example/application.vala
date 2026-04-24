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

namespace Wakit.Example
{

  public sealed class Application: Wakit.Application
    {

      public Application ()
        {

          Object (application_id: "org.hck.wakit.Example",
                           flags: GLib.ApplicationFlags.HANDLES_OPEN,
                         version: Config.PACKAGE_VERSION);
        }

      public override void activate ()
        {

          GLib.File file = GLib.File.new_for_uri ("app:///");
          GLib.File files [1] = { file };

          open (files, "");
        }

      public override void constructed ()
        {

          base.constructed ();
          add_main_option ("bundle", 0, 0, GLib.OptionArg.FILENAME, "bundle.gresource", "Application bundle to serve");
        }

      public override int handle_local_options (GLib.VariantDict options)
        {

          GLib.Variant? value = null;

          if (null != (value = options.lookup_value ("bundle", (GLib.VariantType) "ay")))
            {

              var filename = value.get_bytestring ();

              try
                { var bundle = new Bundle.Bundle.from_file (filename);
                  var pattern = new GLib.Regex ("^/$", GLib.RegexCompileFlags.OPTIMIZE,
                                                                GLib.RegexMatchFlags.DEFAULT);
                  bundle.add_alias (new Bundle.RegexAlias (pattern, "/index.html"));
                  bundle.add_alias (new Bundle.VerbatimAlias ());
                  Bundle.register_uri_scheme_in_bundle ("app", browser, bundle); }
              catch (GLib.Error error)
                {
                  unowned uint code = error.code;
                  unowned string domain = error.domain.to_string ();
                  unowned string message = error.message.to_string ();

                  printerr ("Wakit.Bundle.Bundle.from_file ()!: %s: %u: %s", domain, code, message);
                  return -1;
                }
            }
        return base.handle_local_options (options);
        }

      public static int main (string[] argv)
        {

          var app = new Application ();

          app.appbus.postables.add (new InterfaceImpl ());
          app.extension_host.extension_dir = "src/extension/";

        return app.run (argv);
        }

      private void open_uri (GLib.File file, string hint)
        {

          var window = new Gtk.ApplicationWindow (this);
          var web_view = browser.create_view ();

          window.set_child (web_view);
          window.set_default_size (800, 600);

          web_view.open_uri (file, hint);

          window.present ();
        }

      public override void open_uris ([CCode (array_length_cname = "n_files", array_length_pos = 1.5)] GLib.File[] files, string hint)
        {

          foreach (unowned var file in files)
            open_uri (file, hint);
        }
    }
}