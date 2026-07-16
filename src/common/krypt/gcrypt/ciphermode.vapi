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

  [CCode (cheader_filename = "common/krypt/gcrypt/gcryptapi.h", cname = "enum gcry_cipher_modes", has_type_id = false)]
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