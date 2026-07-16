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

  [CCode (cheader_filename = "common/krypt/gcrypt/gcryptapi.h")]
  namespace Kdf
    {

      public void derive (uint8[] passphrase, KdfAlgo algo, ChecksumAlgo subalgo, uint8[] salt, ulong iterations, uint8[] key) throws GCrypt.Error
        {

          ErrorCode code;

          if (GLib.unlikely (0 != (code = _derive (passphrase, algo, subalgo, salt, iterations, key))))
            throw code.to_error ();
        }

      [CCode (cheader_filename = "gcrypt.h", cname = "gcry_kdf_derive")]
      private ErrorCode _derive ([CCode (array_length_pos = 1.1, array_length_type = "size_t", type = "const void*")] uint8[] passphrase,
                                 KdfAlgo algo,
                                 ChecksumAlgo subalgo,
                                 [CCode (array_length_pos = 4.1, array_length_type = "size_t", type = "const void*")] uint8[] salt,
                                 ulong iterations,
                                 [CCode (array_length_pos = 5.9, array_length_type = "size_t", type = "void*")] uint8[] key);
    }
}
