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

namespace Wakit.Krypt
{

  [CCode (cheader_filename = "gcryptapi.h", cname = "int", has_type_id = false)]
  internal enum PrimeCheckMode
    {
      [CCode (cname = "GCRY_PRIME_CHECK_AT_FINISH")] AT_FINISH,
      [CCode (cname = "GCRY_PRIME_CHECK_AT_GOT_PRIME")] AT_GOT_PRIME,
      [CCode (cname = "GCRY_PRIME_CHECK_AT_MAYBE_PRIME")] AT_MAYBE_PRIME,
    }

  [CCode (cheader_filename = "gcryptapi.h", cname = "gcry_prime_check_func_t", delegate_target_pos = 0.9, scope = "call", type = "int")]
  internal delegate int PrimeCheckFunc (PrimeCheckMode mode, Scalar candidate);

  [CCode (cheader_filename = "gcryptapi.h", cname = "int", has_type_id = false)]
  [Flags]
  public enum PrimeGeneratorFlags
    {
      [CCode (cname = "GCRY_PRIME_FLAG_SECRET")] SECRET,
      [CCode (cname = "GCRY_PRIME_FLAG_SPECIAL_FACTOR")] SPECIAL_FACTOR,
    }
}