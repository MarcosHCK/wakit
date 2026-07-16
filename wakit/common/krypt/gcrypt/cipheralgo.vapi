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

  [CCode (cheader_filename = "wakit/common/krypt/gcrypt/gcryptapi.h", cname = "enum gcry_cipher_algos", has_type_id = false)]
  public enum CipherAlgo
    {

      [CCode (cname = "GCRY_CIPHER_NONE")] NONE,
      [CCode (cname = "GCRY_CIPHER_IDEA")] IDEA,
      [CCode (cname = "GCRY_CIPHER_3DES")] THREEDES,
      [CCode (cname = "GCRY_CIPHER_CAST5")] CAST5,
      [CCode (cname = "GCRY_CIPHER_BLOWFISH")] BLOWFISH,
      [CCode (cname = "GCRY_CIPHER_SAFER_SK128")] SAFER_SK128,
      [CCode (cname = "GCRY_CIPHER_DES_SK")] DES_SK,
      [CCode (cname = "GCRY_CIPHER_AES")] AES,
      [CCode (cname = "GCRY_CIPHER_AES192")] AES192,
      [CCode (cname = "GCRY_CIPHER_AES256")] AES256,
      [CCode (cname = "GCRY_CIPHER_TWOFISH")] TWOFISH,
      [CCode (cname = "GCRY_CIPHER_ARCFOUR")] ARCFOUR,
      [CCode (cname = "GCRY_CIPHER_DES")] DES,
      [CCode (cname = "GCRY_CIPHER_TWOFISH128")] TWOFISH128,
      [CCode (cname = "GCRY_CIPHER_SERPENT128")] SERPENT128,
      [CCode (cname = "GCRY_CIPHER_SERPENT192")] SERPENT192,
      [CCode (cname = "GCRY_CIPHER_SERPENT256")] SERPENT256,
      [CCode (cname = "GCRY_CIPHER_RFC2268_40")] RFC2268_40,
      [CCode (cname = "GCRY_CIPHER_RFC2268_128")] RFC2268_128,
      [CCode (cname = "GCRY_CIPHER_SEED")] SEED,
      [CCode (cname = "GCRY_CIPHER_CAMELLIA128")] CAMELLIA128,
      [CCode (cname = "GCRY_CIPHER_CAMELLIA192")] CAMELLIA192,
      [CCode (cname = "GCRY_CIPHER_CAMELLIA256")] CAMELLIA256,
      [CCode (cname = "GCRY_CIPHER_SALSA20")] SALSA20,
      [CCode (cname = "GCRY_CIPHER_SALSA20R12")] SALSA20R12,
      [CCode (cname = "GCRY_CIPHER_GOST28147")] GOST28147,
      [CCode (cname = "GCRY_CIPHER_CHACHA20")] CHACHA20,
      [CCode (cname = "GCRY_CIPHER_GOST28147_MESH")] GOST28147_MESH,
      [CCode (cname = "GCRY_CIPHER_SM4")] SM4;

      [CCode (cname = "gcry_cipher_get_algo_blklen")]
      public uint get_blocksz ();
      [CCode (cname = "gcry_cipher_get_algo_keylen")]
      public uint get_keylen ();

      [CCode (cname = "gcry_cipher_map_name")]
      public static CipherAlgo parse (string name);
      [CCode (cname = "gcry_cipher_algo_name")]
      public unowned string to_string ();
    }
}