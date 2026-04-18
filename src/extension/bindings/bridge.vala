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

  public sealed class Bridge: GLib.Object, IBinding<Bridge>, IAttributable<Bridge>
    {

      private GLib.HashTable<string, BridgeLane> _lane_table;
      private GLib.HashTable<string, GLib.DBusNodeInfo> _node_table;
      private BridgeTypes _types;

      public string bus_name { get; construct; }
      public GLib.DBusConnection connection { get; construct; }
      public int timeout_msec { get; construct set; default = 1000; }

      public Bridge (GLib.DBusConnection connection, string bus_name, int timeout_msec = 1000)
        {

          Object (bus_name: bus_name, connection: connection, timeout_msec: timeout_msec);
        }

      public override void constructed ()
        {

          base.constructed ();

          unowned GLib.HashFunc<string> hash_func = GLib.str_hash;
          unowned GLib.EqualFunc<string> key_equal_func = GLib.str_equal;

          _lane_table = new GLib.HashTable<string, BridgeLane> (hash_func, key_equal_func);
          _node_table = new GLib.HashTable<string, GLib.DBusNodeInfo> (hash_func, key_equal_func);
          _types = new BridgeTypes ();
        }

      private async GLib.DBusProxy create_proxy (string object_path, string interface_name, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          unowned var flags = GLib.DBusProxyFlags.NONE;
          unowned var info = yield lookup_info (object_path, interface_name, cancellable);
          unowned var name = _bus_name;

        return yield new GLib.DBusProxy (_connection, flags, info, name, object_path, interface_name);
        }

      private void create_proxy_finished (Promise p, GLib.Type type, GLib.AsyncResult result)
        {
  
          try
            { var dbus_proxy = (GLib.DBusProxy) create_proxy.end (result);
              var proxy_base = (IBinding) GLib.Object.new (type, "dbus-proxy", dbus_proxy, null);
              p.resolve (proxy_base.to_value (p.context)); }
          catch (GLib.Error error)
            { p.reject_gerror ((owned) error); }
        }

      public new override JSC.Value? get_property (JSC.Context context, string property_name) throws GLib.Error
        {

          unowned GLib.Cancellable? cancellable = null;
          unowned BridgeLane? lane;

          if (null == (lane = _lane_table.lookup (property_name)))
            {

              throw new GLib.IOError.NOT_FOUND ("unknown lane '%s'", property_name);
            }

          unowned string interface_name = lane.interface_name;
          unowned string object_path = lane.object_path;
          unowned string type_name = lane.type_name;
          unowned GLib.Type type = _types.lookup (type_name);

          return Promise.create (context, p => create_proxy.begin (object_path, interface_name, cancellable,
            (o, res)  => ((Bridge) o).create_proxy_finished (p, type, res)));
        }

      private async GLib.DBusNodeInfo introspect (string object_path, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          unowned var bus_name = _bus_name;
          unowned var flag1 = GLib.DBusCallFlags.NO_AUTO_START;
          unowned var flags = flag1;
          unowned var interface_name = "org.freedesktop.DBus.Introspectable";
          unowned var method_name = "Introspect";
          unowned var parameters = (GLib.Variant?) null;
          unowned var reply_type = (GLib.VariantType) "(s)";
          unowned var timeout_msec = _timeout_msec;

          var reply = yield _connection.call (bus_name, object_path, interface_name, method_name, parameters, reply_type, flags, timeout_msec, cancellable);

        return new GLib.DBusNodeInfo.for_xml (reply.get_child_value (0).get_string ());
        }

      private async unowned GLib.DBusInterfaceInfo lookup_info (string object_path, string interface_name, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          unowned GLib.DBusInterfaceInfo? interface_info;
          unowned GLib.DBusNodeInfo? node_info;

          if (null == (node_info = _node_table.lookup (object_path)))
            {

              var owned_ = yield introspect (object_path, cancellable);

              node_info = owned_;
              _node_table.insert (object_path, (owned) owned_);
            }

          if (null == (interface_info = node_info.lookup_interface (interface_name)))
            {

              throw new GLib.IOError.NOT_FOUND ("interface '%s' don't exist under path '%s'", interface_name, object_path);
            }
        return interface_info;
        }

      public static unowned Class register (JSC.Context context, BridgeLane[] lanes)
        {

          unowned Class klass = IBinding<Bridge>.register (context, "Bridge");

          foreach (unowned var lane in lanes)
            {

              unowned string interface_name = lane.interface_name;
              unowned string property_name = lane.property_name;

              IAttributable<Bridge>.add_property_no_setter (klass, interface_name, property_name);
            }
        return klass;
        }
    }
}