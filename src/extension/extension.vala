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
      private GenericArray<Binding.BridgeLane> _lanes;

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

          GLib.VariantIter iter;
          _parameters.get ("(smsa*m*)", out _eid, out _bus_address, out iter, out _extension_data);

          _lanes = new GenericArray<Binding.BridgeLane> ((uint) iter.n_children ());

          for (GLib.Variant item; null != (item = iter.next_value ());)
            {

              unowned string interface_name;
              unowned string object_path;
              unowned string? property_name = null;
              unowned string? type_name = null;

              item.get ("(&s&sm&sm&s)", out interface_name, out object_path, out property_name, out type_name);

              _lanes.add (new Binding.BridgeLane (interface_name, object_path, property_name, type_name));
            }
        }

      public extern static unowned Wakit.WebExtension get_default ();

      public bool init (GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          script_world = WebKit.ScriptWorld.get_default ();
          script_world.window_object_cleared.connect (on_window_object_cleared);

          unowned string address = _bus_address;
          unowned GLib.DBusConnectionFlags flag1 = GLib.DBusConnectionFlags.AUTHENTICATION_CLIENT;
          unowned GLib.DBusConnectionFlags flag2 = GLib.DBusConnectionFlags.MESSAGE_BUS_CONNECTION;
          unowned GLib.DBusConnectionFlags flags = flag1 | flag2;

          _appbus = new GLib.DBusConnection.for_address_sync (address, flags, null, null);
        return true;
        }

      public extern static unowned Wakit.WebExtension new_default (WebKit.WebProcessExtension wk_extension,
                                                                   [CCode (type = "const GVariant*")]
                                                                   GLib.Variant? parameters,
                                                                   GLib.Type g_type);

      private void on_window_object_cleared (WebKit.WebPage web_page, WebKit.Frame frame)
        {

          var context = frame.get_js_context_for_script_world (script_world);

          registration (context, web_page, frame);
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

          Binding.Bridge.register (context, _lanes.data);
          context.set_value ("bridge", (new Binding.Bridge (_appbus, BUS_NAME)).to_value (context));

          Binding.Testing.register (context).export_global (context);

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