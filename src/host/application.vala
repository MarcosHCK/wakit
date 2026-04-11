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

      private AppBus.Watcher _appbus_watcher;
      private Browser.Maker _browser_maker;
      private GLib.Queue<DeferredUrl?> _deferred_open;

      public IBrowser browser { get { return _browser_maker; } }
      public bool ready { get; private set; default = false; }

      class construct
        {

          if (null == (void*) Wakit.Gui.get_resource ())
            error ("WTF?");
        }

      public override void constructed ()
        {

          base.constructed ();

          _browser_maker = new Browser.Maker ();
          _deferred_open = new GLib.Queue<DeferredUrl?> ();
          _ready = false;
        }

      private void on_daemon_connected (string bus_address, GLib.DBusConnection connection)
        {
        }

      private void on_daemon_crashed (uint tries, GLib.Error error)
        {

          ready = false; if (3 > tries)

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

      public override void shutdown ()
        {

          base.shutdown ();

          var context = GLib.MainContext.ref_thread_default ();
          var loop = new GLib.MainLoop (context, false);

          _appbus_watcher.quit_async.begin ((o, res) =>
            {
              ((AppBus.Watcher) o).quit_async.end (res);
              loop.quit ();
            });

        loop.run ();
        }

      public override void startup ()
        {

          base.startup ();

          _appbus_watcher = new AppBus.Watcher ();

          _appbus_watcher.connected.connect (on_daemon_connected);
          _appbus_watcher.crashed.connect (on_daemon_crashed);
          _appbus_watcher.restart ();
        }
    }
}