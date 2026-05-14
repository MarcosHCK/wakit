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

      private uint64 _start_time = GLib.get_monotonic_time ();
      private bool _with_frame = true;

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
          add_main_option ("bundle", 0, 0, GLib.OptionArg.FILENAME, "Application bundle to serve", "FILE");
          add_main_option ("tree", 0, 0, GLib.OptionArg.FILENAME, "Application tree to serve", "DIRECTORY");
          add_main_option ("with-frame", 0, 0, GLib.OptionArg.NONE, "Preserve the system's window frame", null);
        }

      public override int handle_local_options (GLib.VariantDict options)
        {

          Loaders.ILoader? loader = null;
          GLib.Variant? value = null;

          if (null != (value = options.lookup_value ("bundle", (GLib.VariantType) "ay")))
            {

              var filename = value.get_bytestring ();

              try
                { loader = new Loaders.BundleLoader.from_file (filename); }
              catch (GLib.Error error)
                {
                  unowned uint code = error.code;
                  unowned string domain = error.domain.to_string ();
                  unowned string message = error.message.to_string ();

                  printerr ("Wakit.Bundle.Bundle.from_file ()!: %s: %u: %s\n", domain, code, message);
                  return 1;
                }
            }

          if (null != (value = options.lookup_value ("tree", (GLib.VariantType) "ay")))
            {

              var dirname = value.get_bytestring ();
              var directory = GLib.File.new_for_commandline_arg (dirname);

              loader = new Loaders.TreeLoader (directory);
            }

          if (null == (value = options.lookup_value ("with-frame", (GLib.VariantType) "b")) || !value.get_boolean ())
            {
              _with_frame = false;
            }

          if (unlikely (null == loader))
            {

              printerr ("please specify one of --bundle or --tree\n");
              return 1;
            }

          try
            { var pattern = new GLib.Regex ("^/$", GLib.RegexCompileFlags.OPTIMIZE,
                                                   GLib.RegexMatchFlags.DEFAULT);
              loader.aliases.add (new Loaders.RegexAlias (pattern, "/app.html")); }
          catch (GLib.Error error)
            { GLib.error ("GLib.Regex ()!: %s: %u: %s", error.domain.to_string (), error.code, error.message); }

          loader.aliases.add (new Loaders.VerbatimAlias ());

          Loaders.register_uri_scheme ("app", browser, loader);
          browser.register_uri_scheme_as_local ("app");

          extension_host.secure_schemes.add ("app");

        return base.handle_local_options (options);
        }

      public static int main (string[] argv)
        {

          var app = new Application ();

          app.appbus.postables.add (new InterfaceImpl ());
          app.extension_host.extension_dir = "src/extension/";

        return app.run (argv);
        }

      [CCode (cheader_filename = "glib.h", cname = "G_USEC_PER_SEC")]
      extern const uint _G_USEC_PER_SEC;

      private void open_uri (GLib.File file, string hint)
        {

          var took = GLib.get_monotonic_time () - _start_time;

          GLib.debug ("open_uri ('%s', '%s') after %.2f ms\n",
            file.get_uri (), hint, (double) took / (double) (_G_USEC_PER_SEC / 1000));

          var window = new Gtk.ApplicationWindow (this);
          var web_view = browser.create_view ();

          window.set_child (web_view);
          window.set_decorated (_with_frame);
          window.set_default_size (800, 600);

          web_view.bind_window (window);
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
