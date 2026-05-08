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

  [CCode (cheader_filename = "src/common/krypt/gcrypt/gcryptapi.h", cname = "struct gcry_md_handle", free_function = "gcry_md_close", has_type_id = false)]
  [Compact (opaque = true)]
  public class Checksum
    {

      public static Checksum open ([CCode (type = "int")] ChecksumAlgo algo, [CCode (type = "int")] ChecksumFlags flags) throws GCrypt.Error
        {

          Checksum checksum;
          ErrorCode code;

          if (GLib.unlikely (0 != (code = _open (out checksum, algo, flags))))
            throw Error.from_code (code);

        return (owned) checksum;
        }

      public bool extract ([CCode (type = "int")] ChecksumAlgo algo, uint8[] buffer) throws GCrypt.Error
        {

          ErrorCode code;

          if (GLib.unlikely (0 != (code = _extract (algo, buffer))))
            throw Error.from_code (code);

        return true;
        }

      public bool setfinal () throws GCrypt.Error
        {

          ErrorCode code;

          if (GLib.unlikely (0 != (code = _setfinal ())))
            throw Error.from_code (code);

        return true;
        }

      public bool setkey (uint8[] key) throws GCrypt.Error
        {

          ErrorCode code;

          if (GLib.unlikely (0 != (code = _setkey (key))))
            throw Error.from_code (code);

        return true;
        }

      public bool write (uint8[] data) throws GCrypt.Error
        {

          ErrorCode code;

          if (GLib.unlikely (0 != (code = _write (data))))
            throw Error.from_code (code);

        return true;
        }

      [CCode (cname = "gcry_md_extract")]
      private ErrorCode _extract ([CCode (type = "int")] ChecksumAlgo algo, [CCode (array_length_pos = 2.1, array_length_type = "size_t")] uint8[] key);
      [CCode (cname = "gcry_md_open")]
      private static ErrorCode _open (out Checksum checksum, [CCode (type = "int")] ChecksumAlgo algo, [CCode (type = "int")] ChecksumFlags flags);
      [CCode (cname = "gcry_md_final")]
      public ErrorCode _setfinal ();
      [CCode (cname = "gcry_md_setkey")]
      private ErrorCode _setkey ([CCode (array_length_pos = 1.1, array_length_type = "size_t")] uint8[] key);
      [CCode (cname = "gcry_md_write")]
      private ErrorCode _write ([CCode (array_length_pos = 1.1, array_length_type = "size_t")] uint8[] data);
    }

  [CCode (cheader_filename = "src/common/krypt/gcrypt/gcryptapi.h", cname = "enum gcry_md_algos", has_type_id = false)]
  public enum ChecksumAlgo
    {

      [CCode (cname = "GCRY_MD_NONE")] NONE,
      [CCode (cname = "GCRY_MD_MD5")] MD5,
      [CCode (cname = "GCRY_MD_SHA1")] SHA1,
      [CCode (cname = "GCRY_MD_RMD160")] RMD160,
      [CCode (cname = "GCRY_MD_MD2")] MD2,
      [CCode (cname = "GCRY_MD_TIGER")] TIGER,
      [CCode (cname = "GCRY_MD_HAVAL")] HAVAL,
      [CCode (cname = "GCRY_MD_SHA256")] SHA256,
      [CCode (cname = "GCRY_MD_SHA384")] SHA384,
      [CCode (cname = "GCRY_MD_SHA512")] SHA512,
      [CCode (cname = "GCRY_MD_SHA224")] SHA224,
      [CCode (cname = "GCRY_MD_MD4")] MD4,
      [CCode (cname = "GCRY_MD_CRC32")] CRC32,
      [CCode (cname = "GCRY_MD_CRC32_RFC151")] CRC32_RFC151,
      [CCode (cname = "GCRY_MD_CRC24_RFC244")] CRC24_RFC244,
      [CCode (cname = "GCRY_MD_WHIRLPOOL")] WHIRLPOOL,
      [CCode (cname = "GCRY_MD_TIGER1")] TIGER1,
      [CCode (cname = "GCRY_MD_TIGER2")] TIGER2,
      [CCode (cname = "GCRY_MD_GOSTR3411_94")] GOSTR3411_94,
      [CCode (cname = "GCRY_MD_STRIBOG256")] STRIBOG256,
      [CCode (cname = "GCRY_MD_STRIBOG512")] STRIBOG512,
      [CCode (cname = "GCRY_MD_GOSTR3411_CP")] GOSTR3411_CP,
      [CCode (cname = "GCRY_MD_SHA3_224")] SHA3_224,
      [CCode (cname = "GCRY_MD_SHA3_256")] SHA3_256,
      [CCode (cname = "GCRY_MD_SHA3_384")] SHA3_384,
      [CCode (cname = "GCRY_MD_SHA3_512")] SHA3_512,
      [CCode (cname = "GCRY_MD_SHAKE128")] SHAKE128,
      [CCode (cname = "GCRY_MD_SHAKE256")] SHAKE256,
      [CCode (cname = "GCRY_MD_BLAKE2B_512")] BLAKE2B_512,
      [CCode (cname = "GCRY_MD_BLAKE2B_384")] BLAKE2B_384,
      [CCode (cname = "GCRY_MD_BLAKE2B_256")] BLAKE2B_256,
      [CCode (cname = "GCRY_MD_BLAKE2B_160")] BLAKE2B_160,
      [CCode (cname = "GCRY_MD_BLAKE2S_256")] BLAKE2S_256,
      [CCode (cname = "GCRY_MD_BLAKE2S_224")] BLAKE2S_224,
      [CCode (cname = "GCRY_MD_BLAKE2S_160")] BLAKE2S_160,
      [CCode (cname = "GCRY_MD_BLAKE2S_128")] BLAKE2S_128,
      [CCode (cname = "GCRY_MD_SM3")] SM3,
      [CCode (cname = "GCRY_MD_SHA512_256")] SHA512_256,
      [CCode (cname = "GCRY_MD_SHA512_224")] SHA512_224,
      [CCode (cname = "GCRY_MD_CSHAKE128")] CSHAKE128,
      [CCode (cname = "GCRY_MD_CSHAKE256")] CSHAKE256;

      [CCode (cname = "gcry_md_get_algo_dlen")]
      public uint get_digest_len ();
    }

  [CCode (cheader_filename = "src/common/krypt/gcrypt/gcryptapi.h", cname = "enum gcry_md_flags", has_type_id = false)]
  public enum ChecksumFlags
    {

      [CCode (cname = "GCRY_MD_FLAG_SECURE")] SECURE,
      [CCode (cname = "GCRY_MD_FLAG_HMAC")] HMAC,
      [CCode (cname = "GCRY_MD_FLAG_BUGEMU1")] BUGEMU1,
    }
}