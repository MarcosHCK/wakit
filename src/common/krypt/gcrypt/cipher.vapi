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

  [CCode (cheader_filename = "src/common/krypt/gcrypt/gcryptapi.h", cname = "struct gcry_cipher_handle", free_function = "gcry_cipher_close", has_type_id = false)]
  [Compact (opaque = true)]
  public class Cipher
    {

      public bool decrypt (uint8[] @out, uint8[] @in) throws GCrypt.Error
        {

          ErrorCode code;

          if (GLib.unlikely (0 != (code = _decrypt (@out, @in))))
            throw Error.from_code (code);

        return true;
        }

      public bool encrypt (uint8[] @out, uint8[] @in) throws GCrypt.Error
        {

          ErrorCode code;

          if (GLib.unlikely (0 != (code = _encrypt (@out, @in))))
            throw Error.from_code (code);

        return true;
        }

      public static Cipher open ([CCode (type = "int")] CipherAlgo algo, [CCode (type = "int")] CipherMode mode, [CCode (type = "int")] CipherFlags flags) throws GCrypt.Error
        {

          Cipher cipher;
          ErrorCode code;

          if (GLib.unlikely (0 != (code = _open (out cipher, algo, mode, flags))))
            throw Error.from_code (code);

        return (owned) cipher;
        }

      public bool reset () throws GCrypt.Error
        {

          ErrorCode code;

          if (GLib.unlikely (0 != (code = _reset ())))
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

      [CCode (cname = "gcry_cipher_decrypt")]
      private ErrorCode _decrypt ([CCode (array_length_pos = 1.1, array_length_type = "size_t")] uint8[] @out, [CCode (array_length_pos = 2.1, array_length_type = "size_t")] uint8[] @in);
      [CCode (cname = "gcry_cipher_encrypt")]
      private ErrorCode _encrypt ([CCode (array_length_pos = 1.1, array_length_type = "size_t")] uint8[] @out, [CCode (array_length_pos = 2.1, array_length_type = "size_t")] uint8[] @in);
      [CCode (cname = "gcry_cipher_open")]
      private static ErrorCode _open (out Cipher cipher, [CCode (type = "int")] CipherAlgo algo, [CCode (type = "int")] CipherMode mode, [CCode (type = "int")] CipherFlags flags);
      [CCode (cname = "gcry_cipher_setkey")]
      private ErrorCode _setkey ([CCode (array_length_pos = 1.1, array_length_type = "size_t")] uint8[] key);
      [CCode (cname = "gcry_cipher_reset")]
      public ErrorCode _reset ();
      [CCode (cname = "gcry_cipher_final")]
      public ErrorCode _setfinal ();
    }

  [CCode (cheader_filename = "src/common/krypt/gcrypt/gcryptapi.h", cname = "enum gcry_cipher_algos", has_type_id = false)]
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

  [CCode (cheader_filename = "src/common/krypt/gcrypt/gcryptapi.h", cname = "enum gcry_cipher_modes", has_type_id = false)]
  public enum CipherMode
    {

      [CCode (cname = "GCRY_CIPHER_MODE_NONE")] NONE,
      [CCode (cname = "GCRY_CIPHER_MODE_ECB")] ECB,
      [CCode (cname = "GCRY_CIPHER_MODE_CFB")] CFB,
      [CCode (cname = "GCRY_CIPHER_MODE_CBC")] CBC,
      [CCode (cname = "GCRY_CIPHER_MODE_STREAM")] STREAM,
      [CCode (cname = "GCRY_CIPHER_MODE_OFB")] OFB,
      [CCode (cname = "GCRY_CIPHER_MODE_CTR")] CTR,
      [CCode (cname = "GCRY_CIPHER_MODE_AESWRAP")] AESWRAP,
      [CCode (cname = "GCRY_CIPHER_MODE_CCM")] CCM,
      [CCode (cname = "GCRY_CIPHER_MODE_GCM")] GCM,
      [CCode (cname = "GCRY_CIPHER_MODE_POLY1305")] POLY1305,
      [CCode (cname = "GCRY_CIPHER_MODE_OCB")] OCB,
      [CCode (cname = "GCRY_CIPHER_MODE_CFB8")] CFB8,
      [CCode (cname = "GCRY_CIPHER_MODE_XTS")] XTS,
      [CCode (cname = "GCRY_CIPHER_MODE_EAX")] EAX,
      [CCode (cname = "GCRY_CIPHER_MODE_SIV")] SIV,
      [CCode (cname = "GCRY_CIPHER_MODE_GCM_SIV")] GCM_SIV;

      public static CipherMode parse (string mode_name) { switch (mode_name)
        {

          case "ECB": return CipherMode.ECB;
          case "CFB": return CipherMode.CFB;
          case "CBC": return CipherMode.CBC;
          case "STREAM": return CipherMode.STREAM;
          case "OFB": return CipherMode.OFB;
          case "CTR": return CipherMode.CTR;
          case "AESWRAP": return CipherMode.AESWRAP;
          case "CCM": return CipherMode.CCM;
          case "GCM": return CipherMode.GCM;
          case "POLY1305": return CipherMode.POLY1305;
          case "OCB": return CipherMode.OCB;
          case "CFB8": return CipherMode.CFB8;
          case "XTS": return CipherMode.XTS;
          case "EAX": return CipherMode.EAX;
          case "SIV": return CipherMode.SIV;
          case "GCM_SIV": return CipherMode.GCM_SIV;
          default: return CipherMode.NONE;
        } }
    }
}