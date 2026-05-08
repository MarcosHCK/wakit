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

  public const uint COOKIE_LENGTH = 32;

  public const uint CHALLENGE_LENGTH = 32;

  public const uint MASTER_KEY_LENGTH = 32;
  public const uint SESSION_KEY = 32;

  public abstract class ProtocolComponent: GLib.Object
    {

      internal const ChecksumAlgo checksum_algo = ChecksumAlgo.SHA256;
      internal const CipherAlgo cipher_algo = CipherAlgo.AES256;
      internal const CipherMode cipher_mode = CipherMode.CTR;
      internal const ExternalFormat format = ExternalFormat.HEX;

      public string master_key { get; construct set; }

      protected Scalar derive_key (uint64 counter, string salt) throws GLib.Error
        {

          GCrypt.Checksum checksum;
          uint8[] _counter = (uint8[]) &counter;
          uint8 pass [COOKIE_LENGTH * 2];

          _counter.length = (int) sizeof (uint64);

          checksum = GCrypt.Checksum.open (checksum_algo, ChecksumFlags.HMAC);
          checksum.setkey (salt.data);
          checksum.write (master_key.data);
          checksum.setfinal ();
          checksum.extract (checksum_algo, pass);

          checksum = GCrypt.Checksum.open (checksum_algo, ChecksumFlags.HMAC);
          checksum.setkey (pass);
          checksum.write (_counter);
          checksum.setfinal ();
          checksum.extract (checksum_algo, pass);

        return 
        }

      protected static Cipher open_cipher () throws GLib.Error
        {

          var cipher = Cipher.open (cipher_algo, cipher_mode, 0);
        return cipher;
        }
    }
}