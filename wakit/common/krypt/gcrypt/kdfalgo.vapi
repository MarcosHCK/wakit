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

namespace Wakit.Krypt.GCrypt
{

  [CCode (cheader_filename = "wakit/common/krypt/gcrypt/gcryptapi.h", cname = "enum gcry_kdf_algos", has_type_id = false)]
  public enum KdfAlgo
    {

      [CCode (cname = "GCRY_KDF_NONE")] NONE,
      [CCode (cname = "GCRY_KDF_SIMPLE_S2K")] SIMPLE_S2K,
      [CCode (cname = "GCRY_KDF_SALTED_S2K")] SALTED_S2K,
      [CCode (cname = "GCRY_KDF_ITERSALTED_S2K")] ITERSALTED_S2K,
      [CCode (cname = "GCRY_KDF_PBKDF1")] PBKDF1,
      [CCode (cname = "GCRY_KDF_PBKDF2")] PBKDF2,
      [CCode (cname = "GCRY_KDF_SCRYPT")] SCRYPT,
      [CCode (cname = "GCRY_KDF_ARGON2")] ARGON2,
      [CCode (cname = "GCRY_KDF_BALLOON")] BALLOON,
    }
}