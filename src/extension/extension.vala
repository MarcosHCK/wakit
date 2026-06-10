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
   * Keep well-known bus things in sync with host/interfaces/appbus.vala
   * - note: the constants named BUS_* on the IAppBus interface
   */

  /**
   * Keep well-known bus things in sync with extension/extension.vala
   * - note: the constants named BUS_* on the WebExtension class
   */

  public class WebExtension: GLib.Object, GLib.Initable, IExtensionDataGuest
    {

      const string BUS_NAME = "org.hck.wakit.AppBus";
      const string BUS_OBJECT_PATH = "/org/hck/wakit/AppBus";

      public ICollection<GLib.Regex> accessible_uri_outsource { get; }
      public ICollection<GLib.Regex> accessible_uri_whitelist { get; }
      public GLib.DBusConnection appbus { get; }
      public string bus_address { get; protected set; }
      public GLib.Variant? extension_data { get; protected set; }
      public string guid { get; protected set; }
      public ICollection<string> secure_schemes { get; }
      public WebKit.ScriptWorld script_world { get; private set; }
      public GLib.Variant parameters { construct; }
      public WebKit.WebProcessExtension wk_extension { get; construct; }

      private Binding.DBusService _dbus_service;
      private bool _ready = false;
      private Binding.ProxyBuilder _proxy_builder;
      private Binding.ProxyLister _proxy_lister;

      internal WebExtension (WebKit.WebProcessExtension wk_extension, GLib.Variant parameters)
        {
          Object (wk_extension: wk_extension, parameters: parameters);
        }

      public override void constructed ()
        {

          base.constructed ();
          unowned GLib.HashFunc<string> hash_func = GLib.str_hash;
          unowned GLib.EqualFunc<string> equal_func = GLib.str_equal;

          _accessible_uri_outsource = new PtrArrayCollection<GLib.Regex> ();
          _accessible_uri_whitelist = new PtrArrayCollection<GLib.Regex> ();
          _secure_schemes = new GenericSetCollection<string> (hash_func, equal_func);

          if (true == deserialize (_parameters))

            _parameters = null;
          else
            error ("bad extension data");

          wk_extension.page_created.connect (on_page_created);
        }

      public extern static unowned Wakit.WebExtension get_default ();

      public bool init (GLib.Cancellable? cancellable) throws GLib.Error
        {

          _script_world = WebKit.ScriptWorld.get_default ();
          _script_world.window_object_cleared.connect (on_window_object_cleared);

          init_async.begin (cancellable, init_complete);
        return true;
        }

      async void init_async (GLib.Cancellable? cancellable) throws GLib.Error
        {

          _appbus = yield AppBus.connect_client (_bus_address, 0, cancellable);

          _dbus_service = new Binding.DBusService (_appbus, BUS_NAME);

          _proxy_builder = new Binding.ProxyBuilder (_dbus_service);
          _proxy_lister = new Binding.ProxyLister (_dbus_service);
        }

      private void init_complete (GLib.Object? o, GLib.AsyncResult result)
        {

          try
            { ((WebExtension) o).init_async.end (result);
              _ready = true; }
          catch (GLib.Error error)
            { GLib.error ("Wakit.WebExtension.init_complete ()!: %s: %u: %s",
                error.domain.to_string (), error.code, error.message); }
        }

      static bool is_uri_accessible (string uri, GenericArray<GLib.Regex> whitelist)
        {

          try
            { return is_uri_accessible_ (uri, whitelist); }
          catch (GLib.Error error)
            { GLib.warning ("Wakit.WebExtension.is_uri_accessible ()!: %s: %u: %s",
                error.domain.to_string (), error.code, error.message); }

        return false;
        }

      static bool is_uri_accessible_ (string uri, GenericArray<GLib.Regex> whitelist) throws GLib.Error
        {

          unowned GLib.RegexMatchFlags match_options = 0;

          foreach (unowned var regex in whitelist)

            if (regex.match_full (uri, -1, 0, match_options, null))
              return true;

        return false;
        }

      static bool is_uri_secure (string uri, GenericSet<string> whitelist)
        {

          var scheme = GLib.Uri.parse_scheme (uri);
          var found = whitelist.contains (scheme);
        return found;
        }

      async Binding.ProxyBase make_browser_window (JSC.Context context, uint64 page_id) throws GLib.Error
        {

          const string bus_name = BUS_NAME;
          const string interface_name = "org.hck.wakit.Browser.Window";
          const string path_format = "%s/windows/%" + uint64.FORMAT;

          var object_path = path_format.printf (BUS_OBJECT_PATH, page_id);
          var dbus_proxy = yield _proxy_builder.create_async (context, bus_name, interface_name, object_path);

        return dbus_proxy;
        }

      static void make_browser_window_complete (JSC.Context context, GLib.Object? o, GLib.AsyncResult res)
        {

          try
            { var dbus_proxy = ((WebExtension) o).make_browser_window.end (res);
              context.set_value ("browserWindow", dbus_proxy.to_value (context)); }
          catch (GLib.Error error)
            { GLib.error ("Wakit.WebExtension.make_browser_window ()!: %s: %u: %s",
                error.domain.to_string (), error.code, error.message); }
        }

      public extern static unowned Wakit.WebExtension new_default (WebKit.WebProcessExtension wk_extension,
                                                                   [CCode (type = "const GVariant*")]
                                                                   GLib.Variant? parameters,
                                                                   GLib.Type g_type);

      private void on_page_created (WebKit.WebPage web_page)
        {

          web_page.send_request.connect (on_send_request);
        }

      private bool on_send_request (WebKit.URIRequest request, WebKit.URIResponse? redirected_response)
        {

          unowned var collection = _accessible_uri_whitelist;
          unowned var uri = request.get_uri ();

        return ! is_uri_secure (uri, ((GenericSetCollection<string>) _secure_schemes).struct)
            && ! is_uri_accessible (uri, ((PtrArrayCollection<GLib.Regex>) collection).struct);
        }

      private void on_window_object_cleared (WebKit.WebPage web_page, WebKit.Frame frame)
        {

          if (! is_uri_secure (frame.get_uri (), ((GenericSetCollection<string>) _secure_schemes).struct))
            return;

          for (var main_context = GLib.MainContext.get_thread_default (); false == _ready; )
            main_context.iteration (false);

          JSC.Context context = frame.get_js_context_for_script_world (_script_world);

          registration (context, web_page, frame);
          context.set_value ("logging", Libraries.Logging.register (context));

          Binding.ProxyBuilder.register (context);
          Binding.ProxyLister.register (context);

          var ready = false;
          unowned var _p_ready = (bool[]) &ready;

          make_browser_window.begin (context, web_page.get_id (), (o, res) =>
            { make_browser_window_complete (context, o, res); _p_ready [0] = true; });

          for (var main_context = GLib.MainContext.get_thread_default (); false == ready; )
            main_context.iteration (false);
        }

      [CCode (cname = "WAKIT_WEB_EXTENSION_GET_CLASS (self)->registration")]
      extern const uintptr registration_actv;

      [CCode (cname = "wakit_web_extension_real_registration")]
      extern const uintptr registration_real;

      [CCode (cname = "wakit_web_extension_signals[WAKIT_WEB_EXTENSION_REGISTRATION_SIGNAL]")]
      extern const uint registration_sid;

      [HasEmitter]
      [Signal (run = "last")]
      public virtual signal void registration (JSC.Context context, WebKit.WebPage web_page, WebKit.Frame frame)
        {

          if (! GLib.Signal.has_handler_pending (this, registration_sid, 0, true)
             && registration_actv == registration_real)
            {

              GLib.warning_once ("Your extension does not implement "
                               + "wakit_web_extension_registration() and has no handlers connected "
                               + "to the 'registration' signal. It should do one of these.");
            }
        }
    }
}
