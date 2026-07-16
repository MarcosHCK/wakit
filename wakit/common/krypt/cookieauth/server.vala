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

  public sealed class Server: ProtocolComponent
    {

      internal uint64 _counter = 0;

      public Server (string master_key, string? auth_scope = null)
        {

          Object (auth_scope: auth_scope ?? "", master_key: master_key);
        }

      public bool check_challenge (Challenge challenge, Response response) throws GCrypt.Error
        {

          uint8 res [CHALLENGE_BYTE_LENGTH];
          Cipher cph = open_session_cipher (challenge.counter, response.iv);

          cph.decrypt (res, response.bytes);

        return 0 == GLib.Memory.cmp (res, challenge.bytes, CHALLENGE_BYTE_LENGTH);
        }

      public Challenge next_challenge ()
        {

          var challenge = new Challenge.next (++_counter);
          randomize (challenge.bytes, RandomnessLevel.WEAK);

        return challenge;
        }
    }
}