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

      private bool with_frame = true;

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

          GLib.Variant? value = null;

          if (null != (value = options.lookup_value ("bundle", (GLib.VariantType) "ay")))
            {

              var filename = value.get_bytestring ();

              try
                { var bundle = new Bundle.Bundle.from_file (filename);
                  var pattern = new GLib.Regex ("^/$", GLib.RegexCompileFlags.OPTIMIZE,
                                                                GLib.RegexMatchFlags.DEFAULT);
                  bundle.aliases.add (new Bundle.RegexAlias (pattern, "/index.html"));
                  bundle.aliases.add (new Bundle.VerbatimAlias ());
                  Bundle.register_uri_scheme_in_bundle ("app", browser, bundle);
                  browser.register_uri_scheme_as_local ("app");
                  extension_host.secure_schemes.add ("app"); }
              catch (GLib.Error error)
                {
                  unowned uint code = error.code;
                  unowned string domain = error.domain.to_string ();
                  unowned string message = error.message.to_string ();

                  printerr ("Wakit.Bundle.Bundle.from_file ()!: %s: %u: %s", domain, code, message);
                  return -1;
                }
            }

          if (null != (value = options.lookup_value ("tree", (GLib.VariantType) "ay")))
            {

              var dirname = value.get_bytestring ();
              var directory = GLib.File.new_for_commandline_arg (dirname);

              browser.register_uri_scheme ("app", r => resolve_tree (r, directory));
              browser.register_uri_scheme_as_local ("app");
              extension_host.secure_schemes.add ("app");
            }

          if (null == (value = options.lookup_value ("with-frame", (GLib.VariantType) "b")) || !value.get_boolean ())
            {
              with_frame = false;
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

          if (! with_frame)
            {

              var bar = new Gtk.HeaderBar ();

              bar.visible = false;
              window.set_titlebar (bar);
            }

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

      static void resolve_tree (IUriRequest request, GLib.File directory)
        {

          string fragment = GLib.Path.skip_root (request.path) ?? request.path;
                 fragment = "" != fragment ? fragment : "app.html";
          GLib.File file = GLib.File.new_build_filename (directory.peek_path (), fragment, null);

          resolve_tree_async.begin (request, file, (o, res) =>
            {
              try
                { resolve_tree_async.end (res); }
              catch (GLib.Error error)
                { request.finish_error (error); }
            });
        }

      const string attribute1 = GLib.FileAttribute.STANDARD_CONTENT_TYPE;
      const string attribute2 = GLib.FileAttribute.STANDARD_SIZE;
      const string attributes = attribute1 + "," + attribute2;

      static async void resolve_tree_async (IUriRequest request, GLib.File file) throws GLib.Error
        {

          unowned GLib.FileQueryInfoFlags flag1 = GLib.FileQueryInfoFlags.NONE;
          unowned GLib.FileQueryInfoFlags flags = flag1;
          unowned int io_priority = GLib.Priority.DEFAULT;

          GLib.FileInfo info = yield file.query_info_async (attributes, flags, io_priority);

          if (! info.has_attribute (GLib.FileAttribute.STANDARD_CONTENT_TYPE))

            yield resolve_tree_async_not_content_type (request, file);
          else
            yield resolve_tree_async_yes_content_type (request, file, info);
        }

      static async void resolve_tree_async_not_content_type (IUriRequest request, GLib.File file) throws GLib.Error
        {

          var mapping = new GLib.MappedFile (file.peek_path (), false);

          var bytes = mapping.get_bytes ();
          var content_type = GLib.ContentType.guess (file.peek_path (), bytes.get_data (), null);
          var stream = new GLib.MemoryInputStream.from_bytes (bytes);

          request.finish (stream, bytes.get_size (), content_type);
        }

      static async void resolve_tree_async_yes_content_type (IUriRequest request, GLib.File file, GLib.FileInfo info) throws GLib.Error
        {

          GLib.InputStream stream = yield file.read_async ();

          unowned string content_type = info.get_content_type ();
          unowned int64 length = info.get_size ();

          request.finish (stream, length, content_type);
        }
    }
}