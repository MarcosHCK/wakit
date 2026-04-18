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

  /**
   * Keep well-known name in sync with extension/extension.vala
   * - note: the constant named BUS_NAME on the Extension class
   */

  public class Application: Gtk.Application
    {

      private AppBus.Bus _appbus_bus;
      private AppBus.Watcher _appbus_watcher;
      private Browser.ExtensionHost _browser_extension_host;
      private Browser.Maker _browser_maker;
      private GLib.Queue<DeferredUrl?> _deferred_open;

      public IAppBus appbus { get { return _appbus_bus; } }
      public IBrowser browser { get { return _browser_maker; } }
      public IExtensionHost extension_host { get { return _browser_extension_host; } }
      public bool ready { get; private set; default = false; }

      const string BUS_NAME = "org.hck.wakit.AppBus";

      public override void constructed ()
        {

          base.constructed ();

          _appbus_bus = new AppBus.Bus (BUS_NAME);
          _appbus_watcher = new AppBus.Watcher ();

          _appbus_watcher.crashed.connect (on_appbus_crashed);

          _browser_maker = new Browser.Maker (application_id);
          _browser_extension_host = new Browser.ExtensionHost (_browser_maker.context);
          _deferred_open = new GLib.Queue<DeferredUrl?> ();
          _ready = false;
        }

      private void on_appbus_crashed (GLib.Error? error)
        {

          if (null == error)

            critical ("AppBus crashed!");
          else
            {
              unowned uint code = error.code;
              unowned string domain = error.domain.to_string ();
              unowned string message = error.message.to_string ();

              critical ("AppBus crashed!: %s: %u: %s", domain, code, message);
            }

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

          _appbus_bus.reap_on_connection (_appbus_watcher.connection);

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

          hold ();
          startup_appbus.begin (null, startup_appbus_finished);
        }

      private async bool startup_appbus (GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          bool result = (yield _appbus_watcher.launch (cancellable))
                     && (yield _appbus_bus.graft_on_connection (_appbus_watcher.connection, cancellable));

          GLib.debug ("AppBus launched (address = '%s')", _appbus_watcher.address);

          var address = new AppBus.Address (_appbus_watcher.address);

          AppBus.AddressOption? opt; switch (address.transport)
            {

            case "nonce-tcp": if (null != (opt = address.lookup_option ("noncefile")))
              _browser_maker.context.add_path_to_sandbox (opt.value, true); break;

            case "unix": if (null != (opt = address.lookup_option ("path")))
              _browser_maker.context.add_path_to_sandbox (opt.value, true); break;
            }

          _browser_extension_host.bus_address = _appbus_watcher.address;

        return result;
        }

      private void startup_complete ()
        {

          var files = new GLib.File [1];
          ready = true;

          DeferredUrl? deferred; while (null != (deferred = _deferred_open.pop_head ()))
            {

              files [0] = deferred.file;
              open_uris (files, deferred.hint);
            }
        }

      private static void startup_appbus_finished (GLib.Object? source_object, GLib.AsyncResult result)
        {

          try
            {

              ((Application) source_object).startup_appbus.end (result);
              ((Application) source_object).startup_complete ();
              ((Application) source_object).release ();
            }
          catch (GLib.Error error)
            {

              unowned uint code = error.code;
              unowned string domain = error.domain.to_string ();
              unowned string message = error.message.to_string ();

              critical ("can not acquire AppBus: %s: %u: %s", domain, code, message);
              ((Application) source_object).quit ();
            }
        }
    }
}