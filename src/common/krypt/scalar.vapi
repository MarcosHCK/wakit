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

  [CCode (cheader_filename = "gcryptapi.h", cname = "struct gcry_mpi", copy_function = "gcry_mpi_copy", free_function = "gcry_mpi_release", has_type_id = false)]
  [Compact (opaque = true)]
  internal class Scalar
    {

      public uint nbits { [CCode (cname = "gcry_mpi_get_nbits")] get; }

      [CCode (cname = "gcry_mpi_new")]
      public Scalar (uint nbits = 0);

      [CCode (cname = "gcry_mpi_cmp")]
      public static int cmp (Scalar a, Scalar b);

      [CCode (cname = "gcry_mpi_copy")]
      public Scalar copy ();

      [CCode (cname = "gcry_mpi_mod")]
      public static void mod (Scalar result, Scalar dividend, Scalar divisor);

      public static Scalar parse (ExternalFormat format, uint8[] buffer, out size_t unscanned = null) throws Krypt.Error
        {

          ErrorCode code;
          Scalar n;

          if (GLib.unlikely (0 != (code = scan (out n, format, & buffer [0], buffer.length, out unscanned))))
            throw Error.from_code (code);

        return (owned) n;
        }

      [CCode (cname = "gcry_prime_generate")]
      static ErrorCode prime_generate (out Scalar prime, uint nbits, uint factor_bits, [CCode (array_length = false, array_null_terminated = true)] out Scalar[] factors, PrimeCheckFunc? check_func, RandomnessLevel level, PrimeGeneratorFlags flags);

      [CCode (cname = "gcry_mpi_print", instance_pos = 4.1)]
      public ErrorCode print (ExternalFormat format, void* buffer, size_t buflen, out size_t written = null);

      public static Scalar random_prime (uint nbits, uint factor_bits, out Scalar[] factors, PrimeCheckFunc? check_func, RandomnessLevel level, PrimeGeneratorFlags flags) throws Krypt.Error
        {

          ErrorCode code;
          Scalar n;

          if (GLib.unlikely (0 != (code = prime_generate (out n, nbits, factor_bits, out factors, check_func, level, flags))))
            throw Error.from_code (code);

        return (owned) n;
        }

      [CCode (cname = "gcry_mpi_scan")]
      public static ErrorCode scan (out Scalar scalar, ExternalFormat format, void* buffer, size_t buflen, out size_t unscanned = null);

      public bool to_buffer (ExternalFormat format, uint8[] buffer, out size_t written = null) throws Krypt.Error
        {

          ErrorCode code;

          if (GLib.unlikely (0 != (code = print (format, (void*) & buffer [0], buffer.length, out written))))
            throw Error.from_code (code);

        return true;
        }
    }
}