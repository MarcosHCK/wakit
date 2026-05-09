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

namespace Wakit.Krypt.Cookie
{

  public const uint BIT_LENGTH = 256;
  public const uint BYTE_LENGTH = BIT_LENGTH >> 3;

  public static void generate (uint8 buffer [BYTE_LENGTH])
    {

      var checksum = new GLib.Checksum (GLib.ChecksumType.SHA256);
      var length = (size_t) buffer.length;

      for (int i = 0; i < GLib.Random.int_range (10, 20); ++i)
        {
          double d = GLib.Random.next_double ();
          checksum.update ((uchar[]) &d, sizeof (double));
        }

      checksum.get_digest (buffer, ref length);
    }
}