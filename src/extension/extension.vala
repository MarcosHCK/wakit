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
   * Keep well-known name in sync with host/application.vala
   * - note: the constant named BUS_NAME on the Application class
   */

  public class WebExtension: GLib.Object, GLib.Initable
    {

      private string _bus_address;
      private string _eid;
      private GenericSet<string> _secure_schemes;

      const string BUS_NAME = "org.hck.wakit.AppBus";

      public GLib.DBusConnection appbus { get; }
      public GLib.Variant? extension_data { get; }
      public WebKit.ScriptWorld script_world { get; private set; }
      public GLib.Variant parameters { construct; }
      public WebKit.WebProcessExtension wk_extension { get; construct; }

      internal WebExtension (WebKit.WebProcessExtension wk_extension, GLib.Variant parameters)
        {
          Object (wk_extension: wk_extension, parameters: parameters);
        }

      public override void constructed ()
        {

          base.constructed ();
          unowned GLib.HashFunc<string> hash_func = GLib.str_hash;
          unowned GLib.EqualFunc<string> equal_func = GLib.str_equal;

          _secure_schemes = new GenericSet<string> (hash_func, equal_func);

          GLib.VariantIter secure_schemes_iter;

          _parameters.get ("(smsasm*)", out _eid, 
                                        out _bus_address,
                                        out secure_schemes_iter,
                                        out _extension_data);

          for (GLib.Variant? value; null != (value = secure_schemes_iter.next_value ());)
            _secure_schemes.add (value.get_string ());
        }

      public extern static unowned Wakit.WebExtension get_default ();

      public bool init (GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          _script_world = WebKit.ScriptWorld.get_default ();
          _script_world.window_object_cleared.connect (on_window_object_cleared);

          unowned string address = _bus_address;
          unowned GLib.DBusConnectionFlags flag1 = GLib.DBusConnectionFlags.AUTHENTICATION_CLIENT;
          unowned GLib.DBusConnectionFlags flag2 = GLib.DBusConnectionFlags.MESSAGE_BUS_CONNECTION;
          unowned GLib.DBusConnectionFlags flags = flag1 | flag2;

          _appbus = new GLib.DBusConnection.for_address_sync (address, flags, null, null);
        return true;
        }

      static bool is_secure (WebKit.Frame frame, GenericSet<string> secure_schemes)
        {

          var scheme = GLib.Uri.parse_scheme (frame.get_uri ());
          var found = secure_schemes.contains (scheme);
        return found;
        }

      public extern static unowned Wakit.WebExtension new_default (WebKit.WebProcessExtension wk_extension,
                                                                   [CCode (type = "const GVariant*")]
                                                                   GLib.Variant? parameters,
                                                                   GLib.Type g_type);

      [CCode (cheader_filename = "extension/extension.h")]
      extern const string JS_CODE;

      [CCode (cheader_filename = "extension/extension.h")]
      extern const uint JS_CODE_LEN;

      private void on_window_object_cleared (WebKit.WebPage web_page, WebKit.Frame frame)
        {

          JSC.Context context = frame.get_js_context_for_script_world (_script_world);

          if (! is_secure (frame, _secure_schemes))
            return;

          context.set_value ("logging", Libraries.Logging.register (context));

          registration (context, web_page, frame);

          Binding.ProxyBuilder.register (context);
          Binding.ProxyLister.register (context);

          var setup = context.evaluate_with_source_uri (JS_CODE, JS_CODE_LEN - 1,
            "wakit:///extension/extension.ts", 1);

          var dbus_service = new Binding.DBusService (_appbus, BUS_NAME);
          var proxyBuilder = (new Binding.ProxyBuilder (dbus_service)).to_value (context);
          var proxyLister = (new Binding.ProxyLister (dbus_service)).to_value (context);
          JSC.Value parameters [] = { proxyBuilder, proxyLister };

          setup.object_get_property ("makeBridge").function_callv (parameters);
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
