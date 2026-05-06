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

namespace Wakit.Busmaster.Bus
{

  [DBus (name = "org.freedesktop.DBus")] internal interface IBus: GLib.Object
    {

      public const string NAME = "org.freedesktop.DBus";
      public const string PATH = "/org/freedesktop/DBus";

      [DBus (name = "NameOwnerChanged")] public abstract signal void name_owner_changed (string name, string old_owner, string new_owner);
      [DBus (name = "NameLost")] public abstract signal void name_lost (string name);
      [DBus (name = "NameAcquired")] public abstract signal void name_acquired (string name);

      [DBus (name = "GetNameOwner")] public abstract async string get_name_owner (string name) throws GLib.Error;
      [DBus (name = "Hello")] public abstract async string hello () throws GLib.Error;
      [DBus (name = "ListActivatableNames")]  public abstract async string[] list_activatable_names () throws GLib.Error;
      [DBus (name = "ListNames")] public abstract async string[] list_names () throws GLib.Error;
      [DBus (name = "StartServiceByName")] public abstract async uint start_service_by_name (string name, uint flags) throws GLib.Error;
    }
}