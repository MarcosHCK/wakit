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

  private static ProxyBuilderTypes _types;
  private static GLib.Mutex _types_lock;

  public sealed class ProxyBuilder: GLib.Object, IBinding<ProxyBuilder>, IInvocable<ProxyBuilder>
    {

      public DBusService dbus_service { get; construct; }

      class construct
        {

          _types = new ProxyBuilderTypes ();
          _types_lock = GLib.Mutex ();
        }

      public ProxyBuilder (DBusService dbus_service)
        {

          Object (dbus_service: dbus_service);
        }

      public async ProxyBase create_async (JSC.Context context, string bus_name, string interface_name, string object_path) throws GLib.Error
        {

          unowned var flag1 = GLib.DBusProxyFlags.DO_NOT_AUTO_START;
          unowned var flag2 = GLib.DBusProxyFlags.GET_INVALIDATED_PROPERTIES;
          unowned var flags = flag1 | flag2;
          unowned var info = yield _dbus_service.lookup_info (bus_name, interface_name, object_path);
          unowned var type = GLib.Type.INVALID;

          yield async_lock (_types_lock);

          if (! _types.lookup_extended (info, null, out type))
            type = _types.add (info);

          if (null == IBinding<ProxyBase>.get_class (context, type))
            ProxyBase.register (context, info, type.name (), type);

          _types_lock.unlock ();

          var dbus_proxy = yield _dbus_service.make_proxy (bus_name, interface_name, object_path, flags);
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

          if (args.length < 3)
            {
              JSC.Context.get_current ().throw ("expected two arguments");
              return null;
            }

          string name = args [0].to_string ();

          if (! GLib.DBus.is_name (name))
            {
              JSC.Context.get_current ().throw ("invalid bus name");
              return null;
            }

          string interface_name = args [1].to_string ();

          if (! GLib.DBus.is_interface_name (interface_name))
            {
              JSC.Context.get_current ().throw ("invalid interface name");
              return null;
            }

          string object_path = args [2].to_string ();

          if (! GLib.Variant.is_object_path (object_path))
            {
              JSC.Context.get_current ().throw ("invalid interface name");
              return null;
            }

          var context = JSC.Context.get_current ();

          return Promise.create (context, p => create_async.begin (p.context, name, interface_name, object_path,
              (o, res)  => ((ProxyBuilder) o).create_complete (p, res)));
        }

      public static unowned Class register (JSC.Context context)
        {

          unowned Class klass = IBinding<ProxyBuilder>.register (context, "Wakit.ProxyBuilder");

          IInvocable<ProxyBuilder>.add_method (klass, "create", (c, a) => c.create_method (a));
        return klass;
        }
    }
}