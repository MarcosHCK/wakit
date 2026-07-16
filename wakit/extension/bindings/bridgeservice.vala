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

  /**
   * Keep well-known bus things in sync with host/interfaces/appbus.vala
   */

  public sealed class BridgeService: GLib.Object, GLib.AsyncInitable, IBinding<BridgeService>
    {

      const string BUS_NAME = "org.hck.wakit.AppBus";
      const string OBJECT_PATH = "/org/hck/wakit/AppBus";

      public DBusService dbus_service { get; construct; }
      public ProxyBuilder proxy_builder { get; construct; }

      private GLib.HashTable<string, GLib.DBusProxy> _exports = new GLib.HashTable<string, GLib.DBusProxy> (GLib.str_hash, GLib.str_equal);

      public async BridgeService (DBusService dbus_service, ProxyBuilder proxy_builder, int io_priority, GLib.Cancellable? cancellable) throws GLib.Error
        {

          Object (dbus_service: dbus_service, proxy_builder: proxy_builder);
          yield init_async (io_priority, cancellable);
        }

      async bool add_exports (string bus_name, string object_path, int io_priority, GLib.Cancellable? cancellable) throws GLib.Error
        {

          var connection = _dbus_service.connection;
          var module = yield new BridgeModule (bus_name, connection, io_priority, cancellable);
          var node_info = yield _dbus_service.lookup_node_info (bus_name, object_path, cancellable);

          foreach (unowned var interface_info in node_info.interfaces) if (! interface_info.name.has_prefix ("org.freedesktop.DBus"))
            {

              unowned var interface_name = interface_info.name;
              var export = yield module.create_export (_dbus_service, interface_name, object_path, cancellable);

              if (null != _exports.lookup (export.type_name))

                warning ("duplicated bridge type '%s'", export.type_name);
              else
                _exports.insert ((owned) export.type_name, export.dbus_proxy);
            }
        return true;
        }

      async bool add_exports_for_names ((unowned string)[] names, int io_priority, GLib.Cancellable? cancellable) throws GLib.Error
        {

          const string object_path = BridgeModule.OBJECT_PATH + "/Types";

          foreach (unowned var name in names)
            yield add_exports (name, object_path, io_priority, cancellable);

        return true;
        }

      public async override bool init_async (int io_priority, GLib.Cancellable? cancellable) throws GLib.Error
        {

          const string bus_name = BUS_NAME;
          const string interface_name = "org.hck.wakit.Host.Module.Registry";
          const string method_name = "list_names";
          const string object_path = OBJECT_PATH;
          const int timeout_msec = -1;
          var connection = _dbus_service.connection;
          unowned var flags = GLib.DBusCallFlags.NO_AUTO_START;
          unowned var parameters = (GLib.Variant?) null;
          unowned var reply_type = (GLib.VariantType) "(as)";

          var reply = yield connection.call (bus_name, object_path, interface_name, method_name, parameters, reply_type, flags, timeout_msec, cancellable);
          var names = reply.get_child_value (0).get_strv ();

        return yield add_exports_for_names (names, io_priority, cancellable);
        }

      public static unowned Class register (JSC.Context context)
        {

          unowned var g_type = typeof (BridgeService);
          unowned var parent_class = (JSC.Class?) null;
          unowned var vtable = vtable_once ();

          unowned Class klass = IBinding<BridgeService>.register_full (context, "Wakit.Bridge", g_type, parent_class, *vtable);
        return klass;
        }

      static JSC.ClassVTable _vtable;
      static size_t _vtable_ptr = 0;

      static unowned JSC.ClassVTable* vtable_once ()
        {

          if (GLib.Once.init_enter (&_vtable_ptr))
            {

              _vtable = { vtable_get_property, null, vtable_has_property, null, vtable_enumerate_property };
              GLib.Once.init_leave (&_vtable_ptr, (size_t) &_vtable);
            }
        return (JSC.ClassVTable*) _vtable_ptr;
        }

      static JSC.Value vtable_get_property (JSC.Class jsc_klass, JSC.Context context, void* instance, string name)
        {

          unowned var bridge_service = (BridgeService) instance;
          unowned var exports = bridge_service._exports;
          unowned var dbus_proxy = exports.lookup (name);

        return null == dbus_proxy ? new JSC.Value.undefined (context) : bridge_service._proxy_builder.create_for_proxy (context, dbus_proxy).to_value (context);
        }

      static bool vtable_has_property (JSC.Class jsc_class, JSC.Context context, void* instance, string name)
        {

          unowned var bridge_service = (BridgeService) instance;
          unowned var exports = bridge_service._exports;

        return exports.contains (name);
        }

      [CCode (array_length = false, array_null_terminated = true, cheader_filename = "wakit/extension/bindings/bridgeservice.c", cname = "_g_strndupv")]
      extern static string[] strndupv ([CCode (array_length_cname = "length", array_length_pos = 1.1, array_length_type = "guint")] string[] strv);

      [CCode (array_length = false, array_null_terminated = true)]
      static string[] vtable_enumerate_property (JSC.Class jsc_class, JSC.Context context, void* instance)
        {

          unowned var bridge_service = (BridgeService) instance;
          unowned var exports = bridge_service._exports;

        return strndupv (exports.get_keys_as_ptr_array ().data);
        }
    }
}