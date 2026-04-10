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

  public class Application: Gtk.Application
    {

      public bool ready { get; private set; default = false; }

      private AppBus.Watcher _appbus_watcher;
      private GLib.Queue<DeferredUrl?> _deferred_open;

      private class string _bus_config_envvar = null;
      private class string _bus_executable_envvar = null;
      private class string _extension_dir = null;
      private class bool _launch_appbus = true;

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

          _deferred_open = new GLib.Queue<DeferredUrl?> ();
          _ready = false;
        }

      private void launch_appbus ()
        {

          string name, value;

          hold ();
          _appbus_watcher = new AppBus.Watcher ();

          if (null != (value = null == (name = _bus_config_envvar) ? null : GLib.Environment.get_variable (name)))
            _appbus_watcher.config = value;

          if (null != (value = null == (name = _bus_executable_envvar) ? null : GLib.Environment.get_variable (name)))
            _appbus_watcher.executable = value;

          _appbus_watcher.connected.connect (on_daemon_connected);
          _appbus_watcher.crashed.connect (on_daemon_crashed);
          _appbus_watcher.restart ();
        }

      private void on_daemon_connected (GLib.DBusConnection connection)
        {
        }

      private void on_daemon_crashed (uint tries, GLib.Error error)
        {

          if (3 > tries)

            // leave a few tries slip through
            return;

          critical ("could not restart the appbus after %u tries", tries);
          quit ();
        }

      public override void open ([CCode (array_length_cname = "n_files", array_length_pos = 1.5)] GLib.File[] files, string hint)
        {

          if (_ready)

            open_uris (files, hint);
          else

            foreach (unowned var file in files)
              _deferred_open.push_tail (DeferredUrl (file, hint));
        }

      [HasEmitter]
      public virtual signal void open_uris ([CCode (array_length_cname = "n_files", array_length_pos = 1.5)] GLib.File[] files, string hint)
        {
          warning ("Wakit.Application unimplemented");
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

          _appbus_watcher.quit_async.begin ((o, res) =>
            {
              ((AppBus.Watcher) o).quit_async.end (res);
              loop.quit ();
            });

        loop.run ();
        }
    }
}