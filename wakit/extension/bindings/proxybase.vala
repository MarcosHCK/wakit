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

namespace Wakit.Binding
{

  public abstract class ProxyBase: GLib.Object, IBinding<ProxyBase>, IAttributable<ProxyBase>, ISignalable<ProxyBase>
    {

      public GLib.DBusProxy dbus_proxy { get; construct set; }
      public Hub signal_hub { get; protected set; default = new Hub (); }

      [CCode (cname = "((guint) sizeof (WakitBindingProxyBaseClass))")]
      internal extern const uint SIZEOF_KLASS;

      [CCode (cname = "((guint) sizeof (WakitBindingProxyBase))")]
      internal extern const uint SIZEOF_INSTANCE;

      static string construct_signature (GLib.DBusArgInfo[] args)
        {
          var builder = new GLib.StringBuilder ("(");

          foreach (unowned var info in args) builder.append (info.signature);
                                             builder.append_c (')');
        return builder.free_and_steal ();
        }

      public override void constructed ()
        {

          base.constructed ();
          _dbus_proxy.g_properties_changed.connect (on_properties_changed);
          _dbus_proxy.g_signal.connect (on_signal);
        }

      public new override JSC.Value? get_property (JSC.Context context, string property_name) throws GLib.Error
        {

          GLib.DBusProxy dbus_proxy;

          if (unlikely (null == (dbus_proxy = _dbus_proxy)))
            throw new GLib.IOError.NOT_CONNECTED (_ ("proxy object is not connected"));

          GLib.Variant? variant;

          if (likely (null != (variant = dbus_proxy.get_cached_property (property_name))))
            return Marshalling.variant_to_jsc_value (context, variant);

          throw new GLib.IOError.INVALID_DATA (_ ("uncached property"));
        }

      static JSC.Value? invoke (DBusProxy dbus_proxy, string method_name, string signature, GenericArray<JSC.Value> a)
        {

          return Promise.create (JSC.Context.get_current (), p =>

            invoke_async.begin (p.context, dbus_proxy, method_name, signature, a, (o, res) =>
              {

                try
                  { p.resolve (invoke_async.end (res)); }
                catch (GLib.Error error)
                  { p.reject_gerror ((owned) error); }
              }));
        }

      static async JSC.Value? invoke_async (JSC.Context c, DBusProxy proxy, string method_name, string signature, GenericArray<JSC.Value> a) throws GLib.Error
        {

          unowned GLib.DBusCallFlags flag1 = GLib.DBusCallFlags.ALLOW_INTERACTIVE_AUTHORIZATION;
          unowned GLib.DBusCallFlags flag2 = GLib.DBusCallFlags.NO_AUTO_START;
          unowned GLib.DBusCallFlags flags = flag1 | flag2;
          unowned GLib.VariantType type = (GLib.VariantType) signature;

          var arguments = new JSC.Value.array_from_garray (c, a);
          var parameters = Marshalling.jsc_value_to_variant (c, type, arguments);
          var result = yield proxy.call (method_name, parameters, flags, -1);

          if (result.n_children () != 1)

            return Marshalling.variant_to_jsc_value (c, result);
          else
            return Marshalling.variant_to_jsc_value (c, result.get_child_value (0));
        }

      private void on_properties_changed (GLib.Variant changed, string[] invalidated)
        {
        }

      private void on_signal (string? sender_name, string signal_name, GLib.Variant parameters)
        {

          _signal_hub.emit_vr (signal_name, parameters);
        }

      public static unowned Class register (JSC.Context context, GLib.DBusInterfaceInfo dbus_info, string? name = null, GLib.Type g_type = typeof (ProxyBase))
        {

          unowned Class klass = IBinding<ProxyBase>.register (context, name ?? dbus_info.name, g_type);

          foreach (unowned var info in dbus_info.methods)
            {

              var method_name = info.name;
              var signature = construct_signature (info.in_args);

              klass.jsc_class.add_method (info.name, (c, a) =>
                invoke (((ProxyBase) c)._dbus_proxy, method_name, signature, a),
              typeof (JSC.Value));
            }

          foreach (unowned var info in dbus_info.properties)
            {

              if (false == (GLib.DBusPropertyInfoFlags.READABLE in info.flags))
                IAttributable<ProxyBase>.add_property_no_setter (klass, info.name, info.name);

              else if (false == (GLib.DBusPropertyInfoFlags.WRITABLE in info.flags))
                IAttributable<ProxyBase>.add_property_no_getter (klass, info.name, info.name);

              else
                IAttributable<ProxyBase>.add_property (klass, info.name, info.name);
            }

          if (0 < dbus_info.signals.length)
            {
              ISignalable<ProxyBase>.prepare (klass, context);
            }

          foreach (unowned var info in dbus_info.signals)
            {

              ISignalable<ProxyBase>.add_signal (klass, info.name, info.name);
            }

        return klass;
        }

      public new override void set_property (JSC.Context context, string property_name, JSC.Value value) throws GLib.Error
        {

          GLib.DBusProxy dbus_proxy;

          if (unlikely (null == (dbus_proxy = _dbus_proxy)))
            throw new GLib.IOError.NOT_CONNECTED (_ ("proxy object is not connected"));

          unowned var dbus_info = dbus_proxy.get_info ();
          unowned var property_info = dbus_info.lookup_property (property_name);
          unowned var type = (GLib.VariantType) property_info.signature;

          var variant = Marshalling.jsc_value_to_variant (context, type, value);

          set_property_async.begin (dbus_proxy, property_name, variant, set_property_complete);
        }

      static async GLib.Variant set_property_async (GLib.DBusProxy dbus_proxy, string property_name, GLib.Variant value) throws GLib.Error
        {

          unowned GLib.DBusCallFlags flag1 = GLib.DBusCallFlags.ALLOW_INTERACTIVE_AUTHORIZATION;
          unowned GLib.DBusCallFlags flag2 = GLib.DBusCallFlags.NO_AUTO_START;
          unowned GLib.DBusCallFlags flags = flag1 | flag2;
          unowned GLib.DBusInterfaceInfo info = dbus_proxy.get_info ();
          unowned string method_name = "org.freedesktop.DBus.Properties.Set";

          GLib.Variant v_interface_name = new GLib.Variant.string (info.name);
          GLib.Variant v_property_name = new GLib.Variant.string (property_name);
          GLib.Variant v_value = new GLib.Variant.variant (value);
          GLib.Variant a_parameters [3] = { v_interface_name, v_property_name, v_value };

          var parameters = new GLib.Variant.tuple (a_parameters);

        return yield dbus_proxy.call (method_name, parameters, flags, -1);
        }

      static void set_property_complete (GLib.Object? source_object, GLib.AsyncResult result)
        {

          try
            { set_property_async.end (result); }
          catch (GLib.Error error)
            { unowned uint code = error.code;
              unowned string domain = error.domain.to_string ();
              unowned string message = error.message.to_string ();
              critical (_ ("can not write property: %s: %u: %s"), domain, code, message); }
        }
    }
}