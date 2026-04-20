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

  public sealed class ProxyLister: GLib.Object, IBinding<ProxyLister>, IInvocable<ProxyLister>
    {

      public DBusService dbus_service { get; construct; }
      private GenericSet<string> _hidden_interfaces;

      public ProxyLister (DBusService dbus_service)
        {

          Object (dbus_service: dbus_service);
        }

      public override void constructed ()
        {

          unowned GLib.EqualFunc<string> equal_func = GLib.str_equal;
          unowned GLib.HashFunc<string> hash_func = GLib.str_hash;

          _hidden_interfaces = new GenericSet<string> (hash_func, equal_func);

          _hidden_interfaces.add ("org.freedesktop.DBus.Properties");
          _hidden_interfaces.add ("org.freedesktop.DBus.Introspectable");
          _hidden_interfaces.add ("org.freedesktop.DBus.Peer");
        }

      async JSC.Value? list_path_async (JSC.Context context, string object_path) throws GLib.Error
        {

          unowned var info = yield _dbus_service.lookup_node_info (object_path);
          var array = new GenericArray<JSC.Value> (info.interfaces.length);

          foreach (unowned var interface_ in info.interfaces)

            if (! _hidden_interfaces.contains (interface_.name))
              array.add (new JSC.Value.string (context, interface_.name));

        return new JSC.Value.array_from_garray (context, array);
        }

      private void list_path_complete (Promise p, GLib.AsyncResult result)
        {

          try
            { p.resolve (list_path_async.end (result)); }
          catch (GLib.Error error)
            { p.reject_gerror ((owned) error); }
        }

      private JSC.Value? list_path_method (GenericArray<JSC.Value> args)
        {

          if (args.length < 1)
            {
              JSC.Context.get_current ().throw ("expected one arguments");
              return null;
            }

          string object_path = args [0].to_string ();

          if (! GLib.Variant.is_object_path (object_path))
            {
              JSC.Context.get_current ().throw ("invalid object path");
              return null;
            }

          unowned JSC.Context context = JSC.Context.get_current ();

          return Promise.create (context, p => list_path_async.begin (context, object_path, (o, res) =>
            ((ProxyLister) o).list_path_complete (p, res)));
        }

      public static unowned Class register (JSC.Context context)
        {

          unowned Class klass = IBinding<ProxyLister>.register (context, "Wakit.ProxyLister");

          IInvocable<ProxyLister>.add_method (klass, "list_path", (c, a) => c.list_path_method (a));
        return klass;
        }
    }
}