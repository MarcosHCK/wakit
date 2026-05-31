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

  /**
   * Keep well-known bus name in sync with extension/extension.ts
   * - note: the constant named MODULE_NAME at the top with
   *   HostApplication.Interface's bus name
   */

  public sealed class HostApplication: GLib.Object
    {

      public string appbus_address { get; construct set; }
      public uint appbus_timeout { get; construct set; default = 1200; }
      public uint launch_timeout { get; construct set; default = 600; }
      public string? module_digest { get; construct set; }
      public string module_filename { get; construct set; }
      public string module_loader { get; construct set; }
      public string module_name { get; construct set; }
      public string module_type_prefix { get; construct set; }

      private GLib.DBusConnection? _connection = null;
      private Host? _host = null;
      private uint _registration_id = 0;

      [DBus (name = "org.hck.wakit.HostApplication")] sealed class Interface: GLib.Object
        {

          [DBus (visible = false)] public string? name { get; construct; }
          [DBus (visible = false)] public string? type_prefix { get; construct; }

          [DBus (name = "get_name")] public async string get_name_ () throws GLib.Error
            {
              return _name ?? "";
            }

          [DBus (name = "get_type_prefix")] public async string get_type_prefix_ () throws GLib.Error
            {
              return _type_prefix ?? "";
            }
        }

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

      static int main (string[] argv)
        {

        return (new HostApplication ()).run ();
        }

      public int run ()
        {

          try
            { return run_ (); }

          catch (GLib.OptionError error)
            { printerr ("%s\n", error.message); }

          catch (GLib.Error error)
            { GLib.critical ("Wakit.Host.Module.HostApplication.run()!: %s: %u: %s",
                error.domain.to_string (), error.code, error.message); }
        return 1;
        }

      private int run_ () throws GLib.Error
        {

          run_parse ();
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
              _connection.unregister_object (_registration_id);
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

          var @interface = (Interface) GLib.Object.new (typeof (Interface),
            "name", _module_name,
            "type-prefix", _module_type_prefix,
            null);

          _registration_id = connection.register_object (IModuleHost.OBJECT_PATH, @interface);

          print ("%s\n", (_connection = connection).unique_name);
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

      private int run_parse () throws GLib.Error
        {

          var stream = CommandLine.get_stdin ();
          var parser = new Json.Parser.immutable_new ();
          parser.load_from_stream (stream);

          var root = parser.steal_root ();
          var arguments = (Arguments) Json.gobject_deserialize (typeof (Arguments), root);

          if (unlikely (null == (_appbus_address = arguments.appbus_address)))
            throw new GLib.OptionError.FAILED ("specify the appbus address");

          if (unlikely (! GLib.DBus.is_address (_appbus_address)))
            throw new GLib.OptionError.FAILED ("invalid appbus address");

          _appbus_timeout = arguments.appbus_timeout;
          _launch_timeout = arguments.launch_timeout;

          if (unlikely (null == (module_filename = arguments.module_filename)))
            throw new GLib.OptionError.FAILED ("specify the module filename");

          if (unlikely (null == (_module_loader = arguments.module_loader)))
            throw new GLib.OptionError.FAILED ("specify the module type");

          GLib.File _file;
          _module_filename = (_file = GLib.File.new_for_commandline_arg (module_filename)).get_path ();

          if (null != (_module_digest = arguments.module_digest)
            && unlikely (false == check_digest (_file, _module_digest)))
            throw new GLib.OptionError.FAILED ("module file digest mismatch");

          _module_name = arguments.module_name;
          _module_type_prefix = arguments.module_type_prefix;
        return 0;
        }

      private bool run_prepare () throws GLib.Error
        {

          var timeout = _launch_timeout;
          var cancellable = new TimeoutCancellable (timeout);

          _host = new Host (_module_filename, _module_loader, cancellable);
        return true;
        }
    }
}