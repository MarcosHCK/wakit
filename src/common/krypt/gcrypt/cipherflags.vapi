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

  [CCode (cheader_filename = "src/common/krypt/gcrypt/gcryptapi.h", cname = "enum gcry_cipher_flags", has_type_id = false)]
  [Flags]
  public enum CipherFlags
    {

      [CCode (cname = "GCRY_CIPHER_SECURE")] SECURE,
      [CCode (cname = "GCRY_CIPHER_ENABLE_SYNC")] ENABLE_SYNC,
      [CCode (cname = "GCRY_CIPHER_CBC_CTS")] CBC_CTS,
      [CCode (cname = "GCRY_CIPHER_CBC_MAC")] CBC_MAC,
      [CCode (cname = "GCRY_CIPHER_EXTENDED")] EXTENDED,
    }
}