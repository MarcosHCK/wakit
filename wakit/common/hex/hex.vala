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

namespace Wakit.Hex
{

  const string CHARSET = "0123456789abcdef";

  public static void from_string (uint8[] buffer, string hex_string, ssize_t length = -1) throws GLib.Error
    {

      uint chars = 0 > length ? hex_string.length : (uint) length;

      if (unlikely (0 < (chars & 1)))
        throw new GLib.NumberParserError.INVALID ("invalid hex string");

      uint bytes = chars >> 1;

      if (unlikely (bytes != buffer.length))
        throw new GLib.NumberParserError.INVALID ("invalid hex string");

      for (uint i = 0, j = 0; i < bytes; ++i, j += 2)
        {

          uint8 b = 0;
          char c;
          bool t;

          if ((t = ((c = hex_string [j + 0]) >= '0' && '9' >= c)) || (c >= 'a' && 'f' >= c))

            b |= t ? c - '0' : (c - 'a' + 10);
          else
            throw new GLib.NumberParserError.INVALID ("invalid hex string char");

          b <<= 4;

          if ((t = ((c = hex_string [j + 1]) >= '0' && '9' >= c)) || (c >= 'a' && 'f' >= c))

            b |= t ? c - '0' : (c - 'a' + 10);
          else
            throw new GLib.NumberParserError.INVALID ("invalid hex string char");

          buffer [i] = b;
        }
    }

  public static string to_string (uint8[] buffer)
    {

      unowned var length = buffer.length;

      var builder = new StringBuilder.sized (length << 1);

      for (size_t i = 0; i < length; ++i)
        {

          uint8 b = buffer [i];
          builder.append_c (CHARSET [b >> 4]);
          builder.append_c (CHARSET [b & 0xf]);
        }
    return builder.free_and_steal ();
    }
}