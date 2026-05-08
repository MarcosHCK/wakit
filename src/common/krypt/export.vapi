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

namespace Wakit.Krypt
{

  [CCode (cheader_filename = "gcryptapi.h", cname = "enum gcry_mpi_format", has_type_id = false)]
  public enum ExternalFormat
    {

      [CCode (cname = "GCRYMPI_FMT_NONE")] NONE,
      [CCode (cname = "GCRYMPI_FMT_STD")] STD,
      [CCode (cname = "GCRYMPI_FMT_PGP")] PGP,
      [CCode (cname = "GCRYMPI_FMT_SSH")] SSH,
      [CCode (cname = "GCRYMPI_FMT_HEX")] HEX,
      [CCode (cname = "GCRYMPI_FMT_USG")] USG,
    }

  [CCode (cheader_filename = "common/krypt/export.c", lower_case_cprefix = "gcrypt_point_pack_")]
  namespace PointPack
    {

      [CCode (cname = "GCRYPT_POINT_PACK_OVERHEAD")]
      internal const uint OVERHEAD;

      [CCode (array_length_pos = 3.1, array_length_type = "guint")]
      internal static uint8[] pack (Scalar x, Scalar y, Scalar z, out void* xp, out uint xB, out void* yp, out uint yB, out void* zp, out uint zB);
      internal static bool unpack ([CCode (array_length_pos = 1.1, array_length_type = "guint")] uint8[] buffer, out void* xp, out uint xB, out void* yp, out uint yB, out void* zp, out uint zB);
    }
}