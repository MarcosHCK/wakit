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

  public sealed class DBusService: GLib.Object
    {

      private GLib.HashTable<string, GLib.DBusNodeInfo> _infos;

      public string bus_name { get; construct; }
      public GLib.DBusConnection connection { get; construct; }
      public int timeout_msec { get; construct set; default = 1000; }

      public DBusService (GLib.DBusConnection connection, string bus_name, int timeout_msec = 1000)
        {

          Object (bus_name: bus_name, connection: connection, timeout_msec: timeout_msec);
        }

      public override void constructed ()
        {

          base.constructed ();

          unowned GLib.HashFunc<string> hash_func = GLib.str_hash;
          unowned GLib.EqualFunc<string> key_equal_func = GLib.str_equal;

          _infos = new GLib.HashTable<string, GLib.DBusNodeInfo> (hash_func, key_equal_func);
        }

      private async GLib.DBusNodeInfo introspect (string bus_name, string object_path, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          unowned var flag1 = GLib.DBusCallFlags.NO_AUTO_START;
          unowned var flags = flag1;
          unowned var interface_name = "org.freedesktop.DBus.Introspectable";
          unowned var method_name = "Introspect";
          unowned var parameters = (GLib.Variant?) null;
          unowned var reply_type = (GLib.VariantType) "(s)";
          unowned var timeout_msec = _timeout_msec;

          GLib.Variant reply = yield _connection.call (bus_name, object_path, interface_name, method_name, parameters, reply_type, flags, timeout_msec, cancellable);

        return new GLib.DBusNodeInfo.for_xml (reply.get_child_value (0).get_string ());
        }

      public async unowned GLib.DBusInterfaceInfo lookup_info (string bus_name, string interface_name, string object_path, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          unowned GLib.DBusInterfaceInfo? interface_info;
          unowned GLib.DBusNodeInfo? node_info;

          node_info = yield lookup_node_info (bus_name, object_path, cancellable);

          if (null == (interface_info = node_info.lookup_interface (interface_name)))
            {

              throw new GLib.IOError.NOT_FOUND (_ ("interface '%s' don't exist under path '%s'"), interface_name, object_path);
            }
        return interface_info;
        }

      public async unowned GLib.DBusNodeInfo lookup_node_info (string bus_name, string object_path, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          unowned GLib.DBusNodeInfo? info;
          var key = bus_name.concat (object_path);

          if (null == (info = _infos.lookup (key)))
            {

              var owned_ = yield introspect (bus_name, object_path, cancellable);

              info = owned_;
              _infos.insert ((owned) key, (owned) owned_);
            }
        return info;
        }

      public async GLib.DBusProxy make_proxy (string bus_name, string interface_name, string object_path, GLib.DBusProxyFlags flags, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          unowned var info = yield lookup_info (bus_name, interface_name, object_path);

        return yield new GLib.DBusProxy (_connection, flags, info, bus_name, object_path, interface_name, cancellable);
        }
    }
}