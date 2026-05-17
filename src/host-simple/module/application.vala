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

namespace Wakit.Simple.Module
{

  public sealed class Application: GLib.Object
    {

      private AppBus.Bus _app_bus;
      private GLib.DBusConnection? _connection = null;
      private GLib.OptionContext _context;
      private TypeModule _type_module;
      private unowned string? _address = null;
      private unowned string? _digest = null;
      private uint _timeout = 1200;

      public IAppBus app_bus { get { return _app_bus; } }
      public string bus_name { set { _app_bus.bus_name = value; } }

      public override void constructed ()
        {

          base.constructed ();
          _app_bus = new AppBus.Bus ();
          _context = new GLib.OptionContext ();

          _context.set_help_enabled (true);
          _context.set_ignore_unknown_options (false);
          _context.set_translation_domain ("en_US");

          GLib.OptionEntry entries [] = {
            { "address", 0, 0, GLib.OptionArg.STRING, ref _address, "AppBus address", "ADDRESS" },
            { "digest", 0, 0, GLib.OptionArg.STRING, ref _digest, "Plugin file digest (default: do not bother)", "SHA512" },
            { "timeout", 0, 0, GLib.OptionArg.INT, ref _timeout, "AppBus timeout (default: 1200)", "MSECS" },
            { null, 0, 0, 0, null, null, null },
          };

          _context.add_main_entries (entries, "en_US");
        }

      static bool check_digest (GLib.File file, string expected) throws GLib.Error
        {

          var checksum = new GLib.Checksum (GLib.ChecksumType.SHA512);
          var buffer = new uint8 [2048];

          var stream = file.read ();

          for (ssize_t read; 0 < (read = stream.read (buffer));)
            checksum.update (buffer, read);

        return GLib.str_equal (expected, checksum.get_string ());
        }

      public override void dispose ()
        {

          var type_module = _type_module;
          base.dispose ();

          type_module?.unuse ();
        }

      public int run ([CCode (array_length_cname = "argc", array_length_pos = 0.9, array_length_type = "int")] string[] argv)
        {

          try
            { return run_ (argv); }

          catch (GLib.OptionError error)
            { printerr ("%s\n", error.message); }

          catch (GLib.Error error)
            { GLib.critical ("Wakit.Simple.Host.run()!: %s: %u: %s",
                error.domain.to_string (), error.code, error.message); }
        return 1;
        }

      private int run_ ([CCode (array_length_cname = "argc", array_length_pos = 0.9, array_length_type = "int")] string[] argv) throws GLib.Error
        {

          var args = CommandLine.ensure_argv (ref argv);
          _context.parse (ref argv);

          if (unlikely (argv.length != 2))
            throw new GLib.OptionError.FAILED ("specify a plugin file");

          if (unlikely (null == _address))
            throw new GLib.OptionError.FAILED ("specify the appbus address");

          var file = GLib.File.new_for_commandline_arg (argv [1]);

          if (null != _digest && unlikely (! check_digest (file, _digest)))
            throw new GLib.OptionError.FAILED ("digest mismatch");

          _context = null;
          (_type_module = new TypeModule (file.get_path (), this)).use ();

          var main_context = GLib.MainContext.ref_thread_default ();
          var main_loop = new GLib.MainLoop (main_context, false);

          var cancellable = new GLib.Cancellable ();
          var interrupt_source = new CommandLine.InterruptSource ();

          launch_async.begin (cancellable, launch_complete);

          interrupt_source.set_callback (() => { cancellable.cancel ();
                                                 main_loop.quit ();
            return GLib.Source.REMOVE; });

          interrupt_source.set_static_name ("[Wakit.Simple.Module.Application]");
          interrupt_source.attach (main_context);
          main_loop.run ();

          if (null != _connection)
            {
              _app_bus.reap_on_connection (_connection);
              _connection.close.begin ();
            }

          while (main_context.iteration (false))
            GLib.Thread.yield ();
        return 0;
        }

      private async bool launch_async (GLib.Cancellable? cancellable) throws GLib.Error
        {

          var connection = yield AppBus.connect_client (_address, 0, cancellable);
          var success = yield _app_bus.graft_on_connection (connection, cancellable);
          _connection = connection;
          print ("%s\n", _app_bus.bus_name);
        return success;
        }

      private void launch_complete (GLib.Object? source_object, GLib.AsyncResult result)
        {

          try
            { ((Application) source_object).launch_async.end (result); }

          catch (GLib.Error error)
            { GLib.critical ("Wakit.Simple.Host.run()!: %s: %u: %s",
                error.domain.to_string (), error.code, error.message); }
        }

      [CCode (cheader_filename = "glib.h", cname = "g_strfreev")]
      extern static void _g_strfreev ([CCode (array_length = false, array_null_terminated = true)] owned string[] strv);
    }
}