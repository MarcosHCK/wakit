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

  public sealed class HostApplication: GLib.Object
    {

      public string appbus_address { get; construct set; }
      public uint appbus_timeout { get; construct set; default = 1200; }
      public string? module_digest { get; construct set; }
      public string module_filename { get; construct set; }
      public string module_loader { get; construct set; }
      public uint module_timeout { get; construct set; default = 600; }

      private GLib.DBusConnection? _connection = null;
      private Host? _host = null;

      public signal void quit ();

      static bool check_digest (GLib.File file, string expected) throws GLib.Error
        {

          var checksum = new GLib.Checksum (GLib.ChecksumType.SHA512);
          var buffer = new uint8 [2048];

          var stream = file.read ();

          for (ssize_t read; 0 < (read = stream.read (buffer));)
            checksum.update (buffer, read);

        return GLib.str_equal (expected, checksum.get_string ());
        }

      public int run ([CCode (array_length_cname = "argc", array_length_pos = 0.9, array_length_type = "int")] string[] argv)
        {

          try
            { return run_ (argv); }

          catch (GLib.OptionError error)
            { printerr ("%s\n", error.message); }

          catch (GLib.Error error)
            { GLib.critical ("Wakit.Host.Module.HostApplication.run()!: %s: %u: %s",
                error.domain.to_string (), error.code, error.message); }
        return 1;
        }

      private int run_ ([CCode (array_length_cname = "argc", array_length_pos = 0.9, array_length_type = "int")] string[] argv) throws GLib.Error
        {

          run_parse (argv);
          run_prepare ();

          var main_context = GLib.MainContext.ref_thread_default ();
          var main_loop = new GLib.MainLoop (main_context, false);

          var signal_id = quit.connect (() => main_loop.quit ());

          var cancellable = new GLib.Cancellable ();
          var interrupt_source = new CommandLine.InterruptSource ();

          run_async.begin (cancellable, run_complete);

          interrupt_source.set_callback (() => { cancellable.cancel ();
                                                 main_loop.quit ();
            return GLib.Source.REMOVE; });

          interrupt_source.set_static_name ("[Wakit.Simple.Module.Application]");
          interrupt_source.attach (main_context);
          main_loop.run ();

          if (likely (null != _connection))
            {
              _host.reap_on_connection (_connection);
              _connection.close.begin ();
            }

          while (main_context.iteration (false))
            GLib.Thread.yield ();

          interrupt_source.destroy ();
          disconnect (signal_id);
        return 0;
        }

      async bool run_async (GLib.Cancellable? cancellable) throws GLib.Error
        {

          var connection = yield AppBus.connect_client (_appbus_address, _appbus_timeout, cancellable);
          var success = _host.graft_on_connection (connection, cancellable);
          _connection = connection;

          print ("%s\n", _connection.unique_name);
        return success;
        }

      private void run_complete (GLib.Object? o, GLib.AsyncResult result)
        {

          try
            { ((HostApplication) o).run_async.end (result);
              return; }

          catch (GLib.OptionError error)
            { printerr ("%s\n", error.message); }

          catch (GLib.Error error)
            { GLib.critical ("Wakit.Host.Module.HostApplication.run()!: %s: %u: %s",
                error.domain.to_string (), error.code, error.message); }

          ((HostApplication) o).quit ();
        }

      private int run_parse ([CCode (array_length_cname = "argc", array_length_pos = 0.9, array_length_type = "int")] string[] argv) throws GLib.Error
        {

          var args = CommandLine.ensure_argv (ref argv);
          var context = new GLib.OptionContext ();

          unowned string? appbus_address = null;
          unowned string? module_digest = null;
          unowned string? module_filename = null;
          unowned string? module_loader = null;

          GLib.OptionEntry entries [] = {
            { "appbus-address", 0, 0, GLib.OptionArg.STRING, ref appbus_address, "AppBus address", "ADDRESS" },
            { "appbus-timeout", 0, 0, GLib.OptionArg.INT, ref _appbus_timeout, "AppBus connection timeout (default: 1200)", "MSECS" },
            { "module-digest", 0, 0, GLib.OptionArg.STRING, ref module_digest, "Module filename digest (default: do not bother)", "SHA512" },
            { "module-loader", 0, 0, GLib.OptionArg.STRING, ref module_loader, "Module loader", "LOADER" },
            { "module-filename", 0, 0, GLib.OptionArg.FILENAME, ref module_filename, "Module filename", "FILE" },
            { "module-timeout", 0, 0, GLib.OptionArg.INT, ref _module_timeout, "Module load timeout (default: 600)", "MSECS" },
            { null, 0, 0, 0, null, null, null },
          };

          context.add_main_entries (entries, "en_US");
          context.set_help_enabled (true);
          context.set_ignore_unknown_options (false);
          context.set_translation_domain ("en_US");
          context.parse (ref argv);

          if (likely (null != appbus_address))

            _appbus_address = appbus_address;
          else
            throw new GLib.OptionError.FAILED ("specify the appbus address");

          if (likely (null != module_loader))

            _module_loader = module_loader;
          else
            throw new GLib.OptionError.FAILED ("specify the module type");

          if (unlikely (null == module_filename))
            throw new GLib.OptionError.FAILED ("specify the module filename");

          GLib.File _file;
          _module_filename = (_file = GLib.File.new_for_commandline_arg (module_filename)).get_path ();

          if (null != _module_digest && unlikely (false == check_digest (_file, _module_digest)))
            throw new GLib.OptionError.FAILED ("module file digest mismatch");

          _g_strfreev ((owned) args);
        return 0;
        }

      [CCode (cheader_filename = "glib.h", cname = "g_strfreev")]
      extern static void _g_strfreev ([CCode (array_length = false, array_null_terminated = true)] owned string[] strv);

      public bool run_prepare () throws GLib.Error
        {

          var timeout = _module_timeout;
          var cancellable = new TimeoutCancellable (timeout);

          _host = new Host (_module_filename, _module_loader, cancellable);
        return true;
        }
    }
}