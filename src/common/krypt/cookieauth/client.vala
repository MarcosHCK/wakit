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

  public sealed class Client: ProtocolComponent, GLib.Initable
    {

      public Client (string master_key) throws GLib.Error
        {
          Object (master_key: master_key);
        }

      public bool init (GLib.Cancellable? cancellable) throws GLib.Error
        {

          uint nbits;
          uint expect = COOKIE_LENGTH << 3;

          if (unlikely (expect != (nbits = Scalar.parse (format, master_key.data, null).nbits)))
            throw new GLib.IOError.INVALID_ARGUMENT ("invalid key (nbits %u differs from expected %u)", nbits, expect);

        return true;
        }

      public Response respond_challenge (Challenge challenge)
        {
        return new Response ();
        }
    }
}