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

  [CCode (cname = "gcry_random_level_t", cheader_filename = "gcryptapi.h", has_type_id = false)]
  public enum RandomnessLevel
    {

      [CCode (cname = "GCRY_WEAK_RANDOM")] WEAK,
      [CCode (cname = "GCRY_STRONG_RANDOM")] STRONG,
      [CCode (cname = "GCRY_VERY_STRONG_RANDOM")] VERY_STRONG,
    }

  [CCode (cheader_filename = "gcryptapi.h", cname = "gcry_randomize")]
  internal void randomize ([CCode (array_length_pos = 1.1, array_length_type = "size_t", type = "void*")] uint8[] buffer, RandomnessLevel level);
}