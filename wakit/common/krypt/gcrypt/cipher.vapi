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

  [CCode (cheader_filename = "wakit/common/krypt/gcrypt/gcryptapi.h", cname = "struct gcry_cipher_handle", free_function = "gcry_cipher_close", has_type_id = false)]
  [Compact (opaque = true)]
  public class Cipher
    {

      [CCode (cheader_filename = "wakit/common/krypt/gcrypt/gcryptapi.h")]
      public Cipher ([CCode (type = "int")] CipherAlgo algo,
                     [CCode (type = "int")] CipherMode mode,
                     [CCode (type = "int")] CipherFlags flags) throws GCrypt.Error;

      public bool decrypt (uint8[] @out, uint8[] @in) throws GCrypt.Error
          requires (@in.length == @out.length)
        {

          ErrorCode code;

          if (GLib.unlikely (0 != (code = _decrypt (@out, @in))))
            throw code.to_error ();

        return true;
        }

      public bool encrypt (uint8[] @out, uint8[] @in) throws GCrypt.Error
          requires (@in.length == @out.length)
        {

          ErrorCode code;

          if (GLib.unlikely (0 != (code = _encrypt (@out, @in))))
            throw code.to_error ();

        return true;
        }

      public bool setiv (uint8[] iv) throws GCrypt.Error
        {

          ErrorCode code;

          if (GLib.unlikely (0 != (code = _setiv (iv))))
            throw code.to_error ();

        return true;
        }

      public bool setkey (uint8[] key) throws GCrypt.Error
        {

          ErrorCode code;

          if (GLib.unlikely (0 != (code = _setkey (key))))
            throw code.to_error ();

        return true;
        }

      [CCode (cname = "gcry_cipher_decrypt")]
      private ErrorCode _decrypt ([CCode (array_length_pos = 1.1, array_length_type = "size_t", type = "void*")] uint8[] @out,
                                  [CCode (array_length_pos = 2.1, array_length_type = "size_t", type = "const void*")] uint8[] @in);

      [CCode (cname = "gcry_cipher_encrypt")]
      private ErrorCode _encrypt ([CCode (array_length_pos = 1.1, array_length_type = "size_t", type = "void*")] uint8[] @out,
                                  [CCode (array_length_pos = 2.1, array_length_type = "size_t", type = "const void*")] uint8[] @in);

      [CCode (cname = "gcry_cipher_setiv")]
      private ErrorCode _setiv ([CCode (array_length_pos = 1.1, array_length_type = "size_t", type = "const void*")] uint8[] iv);

      [CCode (cname = "gcry_cipher_setkey")]
      private ErrorCode _setkey ([CCode (array_length_pos = 1.1, array_length_type = "size_t", type = "const void*")] uint8[] key);
    }
}