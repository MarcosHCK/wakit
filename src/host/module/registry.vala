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

namespace Wakit.Host.Module
{

  public sealed class Registry: GLib.Object, GLib.AsyncInitable
    {

      public string bus_address { get; construct; }
      public Configuration.Config configuration { get; construct; }
      public string host_executable { get; set; }

      public GenericArray<Watcher> watchers { get; }

      public override void constructed ()
        {

          base.constructed ();
          _watchers = new GenericArray<Watcher> ();
        }

      public async bool init_async (int io_priority, GLib.Cancellable? cancellable) throws GLib.Error
          requires (null != init_one)
        {

          yield init_impl (_watchers, configuration.modules.items, io_priority, cancellable);

        return true;
        }

      [CCode (cheader_filename = "host/module/registry.h")]
      extern async bool init_impl (GenericArray<Watcher> watchers,
                                   GenericArray<Configuration.Module> modules,
                                   int io_priority, GLib.Cancellable? cancellable) throws GLib.Error;

      internal async Watcher init_one (Configuration.Module module, int io_priority, GLib.Cancellable? cancellable) throws GLib.Error
        {

          unowned string base_dir = _configuration.modules.base_dir;
          unowned string loader = module.loader;
          unowned string name = module.name;

          uint appbus_timeout = _configuration.appbus_launch_timeout;
          uint launch_timeout = _configuration.modules.launch_timeout;

          string filename = module.file
                         ?? yield search_filename (base_dir, loader, name, io_priority, cancellable);

          var arguments = (Arguments) GLib.Object.new (typeof (Arguments),
            "appbus-address", _bus_address,
            "appbus-timeout", appbus_timeout,
            "launch-timeout", launch_timeout,
            "module-digest", module.digest,
            "module-filename", filename,
            "module-loader", loader,
            "module-name", module.name,
            "module-type-prefix", module.type_prefix,
            null);

          var watcher = (Watcher) GLib.Object.new (typeof (Watcher),
            "arguments", arguments,
            "executable", _host_executable,
            null);

          yield watcher.init_async (io_priority, cancellable);

        return watcher;
        }

      static size_t bigger_string ([CCode (array_length = false, array_null_terminated = true)] string[] strv)
        {

          size_t bigger = 0; foreach (unowned var str in strv)
            bigger = size_t.max (bigger, str.length);

        return bigger;
        }

      static async string search_filename (string? base_dir, string loader, string name, int io_priority, GLib.Cancellable? cancellable) throws GLib.Error
        {

          var expected_mime_type = IModule.get_expected_mime_type (loader);
          var search_patterns = IModule.get_search_patterns (loader);
          var bigger = bigger_string (search_patterns);

          const string attributes = GLib.FileAttribute.STANDARD_CONTENT_TYPE;

          var builder = new StringBuilder.sized (bigger + name.length);

          foreach (unowned var pattern in search_patterns)
            {

              builder.truncate (0);
              builder.append (pattern).replace ("?", name);

              GLib.File file; if (null == base_dir)

                file = GLib.File.new_for_path (builder.str);
              else
                file = GLib.File.new_build_filename (base_dir, builder.str, null);

              GLib.FileInfo info; try
                { info = yield file.query_info_async (attributes, 0, io_priority, cancellable); }

              catch (GLib.IOError.NOT_FOUND error)
                { continue; }

              if (GLib.ContentType.equals (expected_mime_type, info.get_content_type ()) ||
                  GLib.ContentType.is_a (info.get_content_type (), expected_mime_type))

                return file.get_path ();
            }

          throw new GLib.IOError.NOT_FOUND (_ ("module file not found (loader %s, name '%s')"), loader, name);
        }

      public async bool quit_async (uint timeout)
        {

          try
            { return yield quit_impl (_watchers, timeout); }
          catch (GLib.Error error)
            { GLib.critical ("Wakit.Host.Module.Registry.quit_async()!: %s: %u: %s",
                error.domain.to_string (), error.code, error.message); }
        return true;
        }

      [CCode (cheader_filename = "host/module/registry.h")]
      extern async bool quit_impl (GenericArray<Watcher> watchers, uint timeout) throws GLib.Error;
    }
}
