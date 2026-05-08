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

  [Compact (opaque = true)] public class Cookie: GLib.Bytes
    {

      const string charset = "0123456789abcdef";
      const GLib.ChecksumType type = GLib.ChecksumType.SHA1;

      private Cookie (owned uint8[] bytes)
        {
          base.take ((owned) bytes);
        }

      public static Cookie from_string (string cookie) throws GLib.Error
        {

          if (unlikely (0 < (cookie.length & 1)))
            throw new GLib.NumberParserError.INVALID ("invalid cookie value");

          uint length = cookie.length >> 1;

          if (unlikely (length != type.get_length ()))
            throw new GLib.NumberParserError.INVALID ("invalid cookie value");

          var buffer = new uint8 [length];

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

              buffer [i] = b;
            }
        return new Cookie ((owned) buffer);
        }

      public static Cookie generate ()
        {

          var checksum = new GLib.Checksum (type);

          for (int i = 0; i < GLib.Random.int_range (10, 20); ++i)
            {
              double bit = GLib.Random.next_double ();
              checksum.update ((uchar[]) &bit, sizeof (double));
            }
        return generate_finish (checksum);
        }

      private static Cookie generate_finish (GLib.Checksum checksum)
        {

          var buffer = new uint8 [type.get_length ()];
          var length = (size_t) type.get_length ();

          checksum.get_digest (buffer, ref length);

        return new Cookie ((owned) buffer);
        }

      public string to_string ()
        {

          unowned var buffer = (uint8[]) get_data ();
          unowned var length = (size_t) type.get_length ();

          var builder = new StringBuilder.sized (length * 2);

          for (size_t i = 0; i < length; ++i)
            {

              uint8 b = buffer [i];
              builder.append_c (charset [b >> 4]);
              builder.append_c (charset [b & 0xf]);
            }
        return builder.free_and_steal ();
        }
    }
}