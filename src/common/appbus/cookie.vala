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

  [Compact (opaque = true)] public class Cookie
    {

      private uint8 _data [LENGTH];

      const string CHARSET = "0123456789abcdef";
      const uint LENGTH = Wakit.Krypt.Cookie.BYTE_LENGTH;

      public Cookie.random ()
        {

          this ();
          Wakit.Krypt.Cookie.generate (_data);
        }

      public Cookie.from_string (string cookie) throws GLib.Error
        {

          this ();

          if (unlikely (0 < (cookie.length & 1)))
            throw new GLib.NumberParserError.INVALID ("invalid cookie value");

          uint length = cookie.length >> 1;

          if (unlikely (length != Cookie.LENGTH))
            throw new GLib.NumberParserError.INVALID ("invalid cookie value");

          for (uint i = 0, j = 0; i < length; ++i, j += 2)
            {

              uint8 b = 0;
              char c;
              bool t;

              if ((t = ((c = cookie [j + 0]) >= '0' && '9' >= c)) || (c >= 'a' && 'f' >= c))

                b |= t ? c - '0' : (c - 'a' + 10);
              else
                throw new GLib.NumberParserError.INVALID ("invalid cookie value");

              b <<= 4;

              if ((t = ((c = cookie [j + 1]) >= '0' && '9' >= c)) || (c >= 'a' && 'f' >= c))

                b |= t ? c - '0' : (c - 'a' + 10);
              else
                throw new GLib.NumberParserError.INVALID ("invalid cookie value");

              _data [i] = b;
            }
        }

      public string to_string ()
        {

          unowned var buffer = _data;
          unowned var length = Cookie.LENGTH;

          var builder = new StringBuilder.sized (length << 1);

          for (size_t i = 0; i < Cookie.LENGTH; ++i)
            {

              uint8 b = buffer [i];
              builder.append_c (Cookie.CHARSET [b >> 4]);
              builder.append_c (Cookie.CHARSET [b & 0xf]);
            }
        return builder.free_and_steal ();
        }
    }
}