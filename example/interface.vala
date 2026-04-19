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

namespace Wakit.Example
{

  [DBus (name = "org.hck.wakit.Example.Interface")]

  public interface Interface: GLib.Object
    {

      [DBus (name = "AlwaysReturns")]
      public abstract string always_returns (string value) throws GLib.Error;

      [DBus (name = "AlwaysThrows")]
      public abstract string always_throws (string value) throws GLib.Error;

      [DBus (name = "EmitSignal1")]
      public abstract void emit_signal_1 (string value) throws GLib.Error;

      [DBus (name = "RandomNumbers")]
      public abstract uint[] random_numbers () throws GLib.Error;

      [DBus (name = "RandomUUID")]
      public abstract string random_uuid () throws GLib.Error;

      [DBus (name = "RandomUUIDs")]
      public abstract string[] random_uuids () throws GLib.Error;

      [DBus (name = "Signal1")]
      public abstract signal void signal1 (string value);

      [DBus (name = "Store")]
      public abstract string store { owned get; set; }
    }

  public sealed class InterfaceImpl: GLib.Object, IPostable, Interface
    {

      private string _store = "<nothing>";

      public string store { owned get { return _store; } set { _store = value; } }

      public string always_returns (string value) throws GLib.Error
        {

          return value;
        }

      public string always_throws (string value) throws GLib.Error
        {

          throw new GLib.IOError.FAILED ("got '%s'", value);
        }

      public void emit_signal_1 (string value) throws GLib.Error
        {

          signal1 (value);
        }

      [DBus (visible = false)]
      public uint post (GLib.DBusConnection connection, string object_path) throws GLib.Error
        {

          return connection.register_object<Interface> (object_path, this);
        }

      public uint[] random_numbers () throws GLib.Error
        {

          var length = GLib.Random.int_range (2, 20);
          var ar = new uint [length];

          for (int i = 0; i < length; ++i)
            {
              ar[i] = (uint) GLib.Random.next_int ();
            }
        return (owned) ar;
        }

      public string random_uuid () throws GLib.Error
        {

          return GLib.Uuid.string_random ();
        }

      public string[] random_uuids () throws GLib.Error
        {

          var length = GLib.Random.int_range (2, 20);
          var ar = new string [length]; 

          for (int i = 0; i < length; ++i)
            {
              ar[i] = GLib.Uuid.string_random ();
            }
        return (owned) ar;
        }
    }
}