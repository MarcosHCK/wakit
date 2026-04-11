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

namespace Wakit.AppBus
{

  public sealed class Registrar: GLib.Object
    {

      private Impl impl = Impl ();

      ~Registrar ()
        {

          impl.clear ();
        }

      public void clear_last (IBusMaster master)
        {

          impl.clear_last (master);
        }

      public extern async bool switch_to (IBusMaster master, string bus_address, GLib.DBusConnection connection) throws GLib.Error;

      [CCode (cname = "wakit_app_bus_registrar_switch_to")]
      public void switch_to_ (IBusMaster master, string bus_address, GLib.DBusConnection connection, GLib.TaskReadyCallback callback)
        {

          impl.switch_to (master, bus_address, connection, callback);
        }

      public bool switch_to_finish (GLib.AsyncResult result) throws GLib.Error
        {

        return impl.switch_to_finish (result);
        }

      [CCode (cheader_filename = "host/appbus/registrar.h", has_type_id = false)] internal extern struct Impl
        {

          public extern Impl ();
          public extern void clear ();
          public extern bool clear_last (IBusMaster master);
          public extern void switch_to (IBusMaster master, string bus_address, GLib.DBusConnection connection, GLib.TaskReadyCallback callback);
          public extern bool switch_to_finish (GLib.AsyncResult result) throws GLib.Error;
        }
    }
}