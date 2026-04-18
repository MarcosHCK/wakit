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

  public sealed class ProxyBuilder: GLib.Object, IBinding<ProxyBuilder>, IInvocable<ProxyBuilder>
    {

      private GLib.HashTable<string, GLib.DBusNodeInfo> _node_table;
      private ProxyBuilderTypes _types;

      public string bus_name { get; construct; }
      public GLib.DBusConnection connection { get; construct; }
      public int timeout_msec { get; construct set; default = 1000; }

      public ProxyBuilder (GLib.DBusConnection connection, string bus_name, int timeout_msec = 1000)
        {

          Object (bus_name: bus_name, connection: connection, timeout_msec: timeout_msec);
        }

      public override void constructed ()
        {

          base.constructed ();

          unowned GLib.HashFunc<string> hash_func = GLib.str_hash;
          unowned GLib.EqualFunc<string> key_equal_func = GLib.str_equal;

          _node_table = new GLib.HashTable<string, GLib.DBusNodeInfo> (hash_func, key_equal_func);
          _types = new ProxyBuilderTypes ();
        }

      private JSC.Value create (JSC.Context context, string interface_name, string object_path)
        {

          return Promise.create (context, p => create_async.begin (p.context, interface_name, object_path,
            (o, res)  => ((ProxyBuilder) o).create_complete (p, res)));
        }

      async ProxyBase create_async (JSC.Context context, string interface_name, string object_path) throws GLib.Error
        {

          unowned var flag1 = GLib.DBusProxyFlags.DO_NOT_AUTO_START;
          unowned var flag2 = GLib.DBusProxyFlags.GET_INVALIDATED_PROPERTIES;
          unowned var flags = flag1 | flag2;
          unowned var info = yield lookup_info (object_path, interface_name);
          unowned var name = _bus_name;
          unowned var type = GLib.Type.INVALID;

          if (! _types.lookup (interface_name, out type))
            type = _types.add (context, info, interface_name);

          var dbus_proxy = yield new GLib.DBusProxy (_connection, flags, info, name, object_path, interface_name);
          var proxy = GLib.Object.new (type, "dbus-proxy", dbus_proxy, null);
        return (ProxyBase) proxy;
        }

      private void create_complete (Promise p, GLib.AsyncResult result)
        {
  
          try
            { var proxy = (ProxyBase) create_async.end (result);
              p.resolve (proxy.to_value (p.context)); }
          catch (GLib.Error error)
            { p.reject_gerror ((owned) error); }
        }

      private JSC.Value? create_method (GenericArray<JSC.Value> args)
        {

          if (args.length < 2)
            {
              JSC.Context.get_current ().throw ("expected two arguments");
              return null;
            }

          string interface_name = args [0].to_string ();

          if (! GLib.DBus.is_interface_name (interface_name))
            {
              JSC.Context.get_current ().throw ("invalid interface name");
              return null;
            }

          string object_path = args [1].to_string ();

          if (! GLib.Variant.is_object_path (object_path))
            {
              JSC.Context.get_current ().throw ("invalid interface name");
              return null;
            }

        return create (JSC.Context.get_current (), interface_name, object_path);
        }

      private async GLib.DBusNodeInfo introspect (string object_path) throws GLib.Error
        {

          unowned var bus_name = _bus_name;
          unowned var flag1 = GLib.DBusCallFlags.NO_AUTO_START;
          unowned var flags = flag1;
          unowned var interface_name = "org.freedesktop.DBus.Introspectable";
          unowned var method_name = "Introspect";
          unowned var parameters = (GLib.Variant?) null;
          unowned var reply_type = (GLib.VariantType) "(s)";
          unowned var timeout_msec = _timeout_msec;

          var reply = yield _connection.call (bus_name, object_path, interface_name, method_name, parameters, reply_type, flags, timeout_msec);

        return new GLib.DBusNodeInfo.for_xml (reply.get_child_value (0).get_string ());
        }

      private async unowned GLib.DBusInterfaceInfo lookup_info (string object_path, string interface_name) throws GLib.Error
        {

          unowned GLib.DBusInterfaceInfo? interface_info;
          unowned GLib.DBusNodeInfo? node_info;

          if (null == (node_info = _node_table.lookup (object_path)))
            {

              var owned_ = yield introspect (object_path);

              node_info = owned_;
              _node_table.insert (object_path, (owned) owned_);
            }

          if (null == (interface_info = node_info.lookup_interface (interface_name)))
            {

              throw new GLib.IOError.NOT_FOUND ("interface '%s' don't exist under path '%s'", interface_name, object_path);
            }
        return interface_info;
        }

      public static unowned Class register (JSC.Context context)
        {

          unowned Class klass = IBinding<ProxyBuilder>.register (context, "Wakit.ProxyBuilder");

          IInvocable<ProxyBuilder>.add_method (klass, "create", (c, a) => c.create_method (a));
        return klass;
        }
    }
}