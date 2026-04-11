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

  public class Application: Gtk.Application, IBusMaster
    {

      public IBrowser browser { get { return _browser_maker; } }
      public bool ready { get; private set; default = false; }

      private AppBus.Watcher _appbus_watcher;
      private AppBus.Registrar _appbus_registrar;
      private Browser.Maker _browser_maker;
      private GLib.Queue<DeferredUrl?> _deferred_open;

      private class string _bus_config_envvar = null;
      private class string _bus_executable_envvar = null;
      private class string _extension_dir = null;
      private class bool _launch_appbus = true;

      class construct
        {

          typeof (Wakit.AppBus.Registrar).ensure ();
          typeof (Wakit.AppBus.Watcher).ensure ();
          typeof (Wakit.Gui.Window).ensure ();

          if (null == (void*) Wakit.Gui.get_resource ())
            error ("WTF?");
        }

      public override bool IBusMaster.acquire (string bus_address, GLib.DBusConnection connection) throws GLib.Error
        {

          var address = new AppBus.Address (bus_address);
          var result = ((IBusMaster) this).default_acquire (bus_address, connection);

          debug ("Wakit.IBusMaster.acquire ('%s', %p)", bus_address, (void*) connection);

          AppBus.AddressOption? opt; switch (address.transport)
            {

            case "nonce-tcp": if (null != (opt = address.lookup_option ("noncefile")))
              _browser_maker.context.add_path_to_sandbox (opt.value, true); break;

            case "unix": if (null != (opt = address.lookup_option ("path")))
              _browser_maker.context.add_path_to_sandbox (opt.value, true); break;
            }
        return result;
        }

      public class void class_set_bus_config_envvar (string? envvar)
        {
          _bus_config_envvar = envvar;
        }

      public class void class_set_bus_executable_envvar (string? envvar)
        {
          _bus_executable_envvar = envvar;
        }

      public class void class_set_extension_dir (string? dir)
        {
          _extension_dir = dir;
        }

      public class void class_set_launch_appbus (bool launch)
        {
          _launch_appbus = launch;
        }

      public override void constructed ()
        {

          base.constructed ();

          _browser_maker = new Browser.Maker ();
          _deferred_open = new GLib.Queue<DeferredUrl?> ();
          _ready = false;
        }

      private void launch_appbus ()
        {

          string name, value;

          hold ();
          _appbus_watcher = new AppBus.Watcher ();
          _appbus_registrar = new AppBus.Registrar ();

          if (null != (value = null == (name = _bus_config_envvar) ? null : GLib.Environment.get_variable (name)))
            _appbus_watcher.config = value;

          if (null != (value = null == (name = _bus_executable_envvar) ? null : GLib.Environment.get_variable (name)))
            _appbus_watcher.executable = value;

          _appbus_watcher.connected.connect (on_daemon_connected);
          _appbus_watcher.crashed.connect (on_daemon_crashed);
          _appbus_watcher.restart ();
        }

      private void on_daemon_connected (string bus_address, GLib.DBusConnection connection)
        {

          hold ();
          _appbus_registrar.switch_to.begin (this, bus_address, connection, on_registrar_finished);
        }

      private void on_daemon_crashed (uint tries, GLib.Error error)
        {

          ready = false; if (3 > tries)

            // leave a few tries slip through
            return;

          critical ("could not restart the appbus after %u tries", tries);
          quit ();
        }

      private void on_registrar_finished (GLib.Object? source_object, GLib.AsyncResult result)
        {

          bool bootstrap = false; try
            {

              bootstrap = _appbus_registrar.switch_to.end (result);
              ready = true;

              open_deferred ();
            }
          catch (GLib.Error error)
            {

              unowned uint code = error.code;
              unowned string domain = error.domain.to_string ();
              unowned string message = error.message.to_string ();

              critical ("could not register on appbus: %s: %u: %s", domain, code, message);
              quit ();
            }

          for (int i = 0; i < (! bootstrap ? 1 : 2); ++i)
            base.release ();
        }

      public override void open ([CCode (array_length_cname = "n_files", array_length_pos = 1.5)] GLib.File[] files, string hint)
        {

          if (_ready)

            open_uris (files, hint);
          else

            foreach (unowned var file in files)
              _deferred_open.push_tail (DeferredUrl (file, hint));
        }

      private void open_deferred ()
        {

          var files = new GLib.File [1]; 

          DeferredUrl? deferred; while (null != (deferred = _deferred_open.pop_head ()))
            {
              files [0] = deferred.file;
              open_uris (files, deferred.hint);
            }
        }
  
      [CCode (cname = "WAKIT_APPLICATION_GET_CLASS (self)->open_uris")]
      extern const uintptr open_uris_actv;

      [CCode (cname = "wakit_application_real_open_uris")]
      extern const uintptr open_uris_real;

      [CCode (cname = "wakit_application_signals[WAKIT_APPLICATION_OPEN_URIS_SIGNAL]")]
      extern const uint open_uris_sid;

      [HasEmitter]
      [Signal (run = "last")]
      public virtual signal void open_uris ([CCode (array_length_cname = "n_files", array_length_pos = 1.5)] GLib.File[] files, string hint)
        {

          if (! GLib.Signal.has_handler_pending (this, open_uris_sid, 0, true)
             && open_uris_actv == open_uris_real)
            {

              GLib.warning_once ("Your application does not implement "
                               + "wakit_application_open_uris() and has no handlers connected "
                               + "to the 'open_uris' signal. It should do one of these.");
            }
        }

      public override void IBusMaster.release (string bus_address, GLib.DBusConnection connection)
        {

          AppBus.Address address; try
            {
              address = new AppBus.Address (bus_address);
            }
          catch (GLib.Error error)
            {
              unowned uint code = error.code;
              unowned string domain = error.domain.to_string ();
              unowned string message = error.message.to_string ();
              GLib.error ("Wakit.AppBus.Address ()!: %s: %u: %s", domain, code, message);
            }

          ((IBusMaster) this).default_release (bus_address, connection);

          debug ("Wakit.IBusMaster.release ('%s', %p)", bus_address, (void*) connection);
        }

      public override void shutdown ()
        {

          base.shutdown ();

          if (! (ready = false == _launch_appbus))
            terminate_appbus ();
        }

      public override void startup ()
        {

          base.startup ();

          if (! (_ready = false == _launch_appbus))
            launch_appbus ();
        }

      private void terminate_appbus ()
        {

          var context = GLib.MainContext.ref_thread_default ();
          var loop = new GLib.MainLoop (context, false);

          _appbus_registrar.clear_last (this);

          _appbus_watcher.quit_async.begin ((o, res) =>
            {
              ((AppBus.Watcher) o).quit_async.end (res);
              loop.quit ();
            });

        loop.run ();
        }
    }
}