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

namespace Wakit.Browser
{

  [Compact (opaque = true)]
  public class WindowRegistrar
    {

      private GLib.WeakRef _connection;

      public GLib.DBusConnection? connection { owned get { return (GLib.DBusConnection) _connection.get (); }
                                               private set { _connection.set (value); } }

      public uint registration_id { get; private set; }

      ~WindowRegistrar ()
        {

          connection?.unregister_object (registration_id);
        }

      private WindowRegistrar (GLib.DBusConnection connection, uint registration_id)
        {

          this.connection = connection;
          this.registration_id = registration_id;
        }

      [DBus (visible = false)]
      public static void expose (GLib.DBusConnection connection, string object_path, Window window) throws GLib.Error
        {

          var ac = window.web_view;
          var id = connection.register_object<IWindow> (object_path, window);
          var qr = GLib.Quark.from_string (@"wakit-browser-window-registrar-$(id)");

          var rt = new WindowRegistrar (connection, id);

          ac.set_qdata_full (qr, (owned) rt, (GLib.DestroyNotify) WindowRegistrar.free);
        }

      extern void free ();
    }
}