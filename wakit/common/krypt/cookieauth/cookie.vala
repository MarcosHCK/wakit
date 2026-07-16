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
using Wakit.Krypt.GCrypt;

namespace Wakit.Krypt.CookieAuth
{

  [Compact (opaque = true)] public class Cookie
    {

      private uint8 _data [BYTE_LENGTH];

      public Cookie ()
        {
        }

      public Cookie.from_string (string cookie, ssize_t length = -1) throws GLib.Error
        {

          this ();
          Hex.from_string (_data, cookie, length);
        }

      public Cookie.random ()
        {

          this ();
          randomize (_data, RandomnessLevel.VERY_STRONG);
        }

      public string to_string ()
        {

        return Hex.to_string (_data);
        }
    }
}