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

namespace GLib
{

  [CCode (cheader_filename = "gio/gio.h")]
  public class UnixSocketAddress: GLib.SocketAddress
    {

      [CCode (has_construct_function = false, type = "GSocketAddress*")]
      public UnixSocketAddress (string path);
      [CCode (has_construct_function = false, type = "GSocketAddress*")]
      public UnixSocketAddress.with_type (string path, int length = -1, GLib.UnixSocketAddressType type = GLib.UnixSocketAddressType.PATH);
      public static bool abstract_names_supported ();
      public GLib.UnixSocketAddressType get_address_type ();
      public unowned string get_path ();
    }
}