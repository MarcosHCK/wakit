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

  public sealed class Server: ProtocolComponent, GLib.Initable
    {

      internal uint64 _counter = 0;

      public Server (GLib.Cancellable? cancellable = null) throws GLib.Error
        {
          Object ();
          init (cancellable);
        }

      public bool init (GLib.Cancellable? cancellable) throws GLib.Error
        {

          const PrimeGeneratorFlags flags = PrimeGeneratorFlags.SECRET;
          const RandomnessLevel level = RandomnessLevel.VERY_STRONG;
          const uint nbits = MASTER_KEY_LENGTH << 3;

          master_key = Scalar.random_prime (nbits, 0, null, null, level, flags).to_string ();
        return true;
        }

      public Challenge next_challenge ()
        {

        return new Challenge.random (++_counter);
        }
    }
}