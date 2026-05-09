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

  [CCode (cheader_filename = "common/krypt/cookieauth/internal.h")]
  const uint CHALLENGE_BYTE_LENGTH;

  [CCode (cheader_filename = "common/krypt/cookieauth/internal.h")]
  const uint CIPHER_IV_BYTE_LENGTH;

  [CCode (cheader_filename = "common/krypt/cookieauth/protocol.h")]
  public abstract class ProtocolComponent: GLib.Object
    {

      public string auth_scope { [NoAccessorMethod] get; construct; }
      public string master_key { [NoAccessorMethod] get; construct; }

      [CCode (has_construct_function = false)]
      protected ProtocolComponent ();

      [CCode (cheader_filename = "common/krypt/cookieauth/internal.h")]
      internal Cipher open_session_cipher (uint64 counter, uint8 iv [CIPHER_IV_BYTE_LENGTH]) throws GCrypt.Error;
    }
}