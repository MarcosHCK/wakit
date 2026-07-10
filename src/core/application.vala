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

      private AppBus.Bus _appbus_bus;
      private AppBus.Watcher _appbus_watcher;
      private Browser.Browser _browser_browser;
      private Browser.ExtensionHost _browser_extension_host;
      private GLib.Queue<DeferredUrls?> _deferred_open;

      protected string appbus_address { get { return _appbus_watcher.address; } }

      public IAppBus appbus { get { return _appbus_bus; } }
      public IBrowser browser { get { return _browser_browser; } }
      public Configuration.Config? configuration { get; construct; }
      public IExtensionHost extension_host { get { return _browser_extension_host; } }
      public bool ready { get; private set; default = false; }

      public override void constructed ()
        {

          base.constructed ();

          _appbus_bus = new AppBus.Bus ();
          _appbus_watcher = new AppBus.Watcher ();

          _appbus_watcher.crashed.connect (on_appbus_crashed);

          _configuration = _configuration ?? (Configuration.Config) GLib.Object.new (typeof (Configuration.Config),
            "application-id", application_id,
            "application-version", get_version (),
            null);

          _browser_browser = new Browser.Browser (_configuration);
          _browser_extension_host = new Browser.ExtensionHost (_browser_browser.context);
          _deferred_open = new GLib.Queue<DeferredUrls?> ();
          _ready = false;

          _browser_browser.created_view.connect (on_created_view);
        }

      private void on_appbus_crashed (GLib.Error? error)
        {

          if (null == error)

            critical (_ ("AppBus crashed!"));
          else
            {
              unowned uint code = error.code;
              unowned string domain = error.domain.to_string ();
              unowned string message = error.message.to_string ();

              critical (_ ("AppBus crashed!: %s: %u: %s"), domain, code, message);
            }

          quit ();
        }

      private void on_created_view (Wakit.Browser.Widget widget)
        {

          var page_id = widget.web_view.page_id.to_string ();
          var object_path = GLib.Path.build_filename (IAppBus.BUS_OBJECT_PATH, "windows", page_id);

          var connection = _appbus_watcher.connection;
          var window = new Wakit.Browser.Window (widget);

          try
            { Wakit.Browser.WindowRegistrar.expose (connection, object_path, window); }
          catch (GLib.Error error)
            {
              GLib.critical ("Wakit.Browser.WindowRegistrar.expose ()!: %s: %u: %s",
                error.domain.to_string (), error.code, error.message);
              return ;
            }
        }

      public override void open ([CCode (array_length_cname = "n_files", array_length_pos = 1.5)] GLib.File[] files, string hint)
        {

          if (_ready)

            open_uris (files, hint);
          else
            _deferred_open.push_tail (DeferredUrls (files, hint));
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

          shutdown_async.begin ((o, res) =>
            {
              ((Application) o).shutdown_async.end (res);
              loop.quit ();
            });

        loop.run ();
        }

      public virtual async void shutdown_async ()
        {

          _appbus_bus.reap_on_connection (_appbus_watcher.connection);

          yield _appbus_watcher.quit_async (_configuration.appbus_shutdown_timeout);
        }

      public override void startup ()
        {

          base.startup ();

          hold ();
          startup_async.begin (null, startup_finished);
        }

      async bool startup_appbus (GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          var timeout = _configuration.appbus_launch_timeout;

          bool result = (yield _appbus_watcher.launch (timeout, cancellable))
                     && (yield _appbus_bus.graft_on_connection (_appbus_watcher.connection, cancellable));

          GLib.debug ("AppBus launched (address = '%s')", _appbus_watcher.address);

          var address = new AppBus.Address.from_string (_appbus_watcher.address);

          AppBus.AddressOption? opt; switch (address.transport)
            {

            case "nonce-tcp": if (null != (opt = address.lookup_option ("noncefile")))
              _browser_browser.context.add_path_to_sandbox (opt.value, true); break;

            case "unix": if (null != (opt = address.lookup_option ("path")))
              _browser_browser.context.add_path_to_sandbox (opt.value, true); break;
            }

          _browser_extension_host.bus_address = _appbus_watcher.address;

        return result;
        }

      public virtual async bool startup_async (GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          try
            { yield startup_appbus (); }

          catch (GLib.Error error)
            {
              GLib.Error.prefix_literal (out error, _ ("couldn't launch appbus: "));
              throw (owned) error;
            }

        return true;
        }

      void startup_complete ()
        {

          ready = true;

          for (DeferredUrls? deferred; null != (deferred = _deferred_open.pop_head ());)
            open_uris (deferred.files, deferred.hint);
        }

      static void startup_finished (GLib.Object? source_object, GLib.AsyncResult result)
        {

          try
            {
              ((Application) source_object).startup_async.end (result);
              ((Application) source_object).startup_complete ();
              ((Application) source_object).release ();
            }
          catch (GLib.Error error)
            {

              unowned uint code = error.code;
              unowned string domain = error.domain.to_string ();
              unowned string message = error.message.to_string ();

              critical ("Wakit.Application.startup_async()!: %s: %u: %s", domain, code, message);
              ((Application) source_object).quit ();
            }
        }
    }
}