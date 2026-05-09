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

  public sealed class Client: ProtocolComponent
    {

      public Client (string master_key, string? auth_scope = null) throws GLib.Error
        {
          Object (auth_scope: auth_scope ?? "", master_key: master_key);
        }

      public Response respond_challenge (Challenge challenge) throws GCrypt.Error
        {


          var response = new Response ();
          randomize (response.iv, RandomnessLevel.STRONG);

          Cipher cph = open_session_cipher (challenge.counter, response.iv);
          cph.encrypt (response.bytes, challenge.bytes);

        return response;
        }
    }
}