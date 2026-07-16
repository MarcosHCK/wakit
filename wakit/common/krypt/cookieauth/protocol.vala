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
using Wakit.Krypt.GCrypt;

namespace Wakit.Krypt.CookieAuth
{

  public const uint BIT_LENGTH = 256;
  public const uint BYTE_LENGTH = BIT_LENGTH >> 3;
  /* two characters per byte */
  public const uint STRING_LENGTH = BIT_LENGTH >> 2;

  public const uint CHALLENGE_BYTE_LENGTH = BYTE_LENGTH;
  internal const CipherAlgo CIPHER_ALGO = CipherAlgo.AES256;
  internal const CipherMode CIPHER_MODE = CipherMode.CTR;
  public const uint CIPHER_IV_BYTE_LENGTH = 16;
  internal const KdfAlgo KDF_ALGO = KdfAlgo.PBKDF2;
  internal const uint KDF_ITERATIONS = 1024;
  internal const ChecksumAlgo KDF_SUBALGO = ChecksumAlgo.SHA256;

  public abstract class ProtocolComponent: GLib.Object
    {

      public string auth_scope { get; construct; }
      public string master_key { get { return _master_key; }
                                 construct { _set_master_key (value); } }
      private string _master_key = null;

      private void _set_master_key (string new_key) requires (STRING_LENGTH == new_key.length)
        {
          _master_key = new_key;
        }

      private void make_session_key (uint64 counter, uint8 key [BYTE_LENGTH]) throws GCrypt.Error
        {

          unowned var src1 = (uint8[]) _auth_scope.data;
          unowned var src2 = (uint8[]) &counter;
          src2.length = (int) sizeof (uint64);

          var salt = new uint8 [src1.length + src2.length];

          GLib.Memory.copy (&salt [0], src1, src1.length);
          GLib.Memory.copy (&salt [src1.length], src2, src2.length);

          unowned var passphrase = _master_key.data;

          Kdf.derive (passphrase, KDF_ALGO, KDF_SUBALGO, salt, KDF_ITERATIONS, key);
        }

      internal Cipher open_session_cipher (uint64 counter, uint8 iv [CIPHER_IV_BYTE_LENGTH]) throws GCrypt.Error
        {

          Cipher cph = new Cipher (CIPHER_ALGO, CIPHER_MODE, 0);
          uint8 key [BYTE_LENGTH];

          cph.setiv (iv);
          make_session_key (counter, key);
          cph.setkey (key);

        return cph;
        }
    }
}