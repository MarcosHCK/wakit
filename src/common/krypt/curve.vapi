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

  [CCode (cheader_filename = "gcryptapi.h", cname = "struct gcry_context", free_function = "gcry_ctx_release", has_type_id = false)]
  [Compact (opaque = true)]
  internal class Curve
    {

      private Curve ();

      [CCode (cname = "gcry_mpi_ec_get_affine", instance_pos = 3.1)]
      public void affine (Scalar? x, Scalar? y, Point p);

      [CCode (cname = "gcry_mpi_ec_mul", instance_pos = 3.1)]
      public void mul (Point result, Scalar factor, Point point);

      public static Curve named (string curve_name) throws Krypt.Error
        {

          Curve curve;
          ErrorCode code = _new (out curve, null, curve_name);

          if (GLib.unlikely (0 != code))
            throw Error.from_code (code);

        return curve;
        }

      [CCode (cname = "gcry_mpi_ec_get_point", instance_pos = 1.1)]
      public Point? named_point (string name, [CCode (type = "int")] bool no_const = false);
      [CCode (cname = "gcry_mpi_ec_get_mpi", instance_pos = 1.1)]
      public Scalar? named_scalar (string name, [CCode (type = "int")] bool no_const = false);

      [CCode (cname = "gcry_mpi_ec_new")]
      static ErrorCode _new (out Curve curve, void* s_exp, string? curve_name);
    }

  [CCode (cheader_filename = "gcryptapi.h", cname = "struct gcry_mpi_point", free_function = "gcry_mpi_point_release", has_type_id = false)]
  [Compact (opaque = true)]
  internal class Point
    {

      [CCode (cname = "gcry_mpi_point_new")]
      public Point (uint nbits = 0);

      public static int cmp (Point a, Point b)
        {

          uint different = 0;
          var xa = new Scalar (), ya = new Scalar (), za = new Scalar ();
          var xb = new Scalar (), yb = new Scalar (), zb = new Scalar ();

          a.@get (xa, ya, za);
          b.@get (xb, yb, zb);

          different += Scalar.cmp (xa, xb) == 0 ? 0 : 1;
          different += Scalar.cmp (ya, yb) == 0 ? 0 : 1;
          different += Scalar.cmp (za, zb) == 0 ? 0 : 1;
          return (int) different;
        }

      [CCode (cname = "gcry_mpi_point_get", instance_pos = 3.1)]
      public void @get (Scalar x, Scalar y, Scalar z);

      public uint8[] pack () throws Krypt.Error
        {

          Scalar x, y, z;
          uint xB, yB, zB;
          void* xp, yp, zp;

          @get (x = new Scalar (), y = new Scalar (), z = new Scalar ());

          var ar = (uint8[]) PointPack.pack (x, y, z, out xp, out xB, out yp, out yB, out zp, out zB);

          unowned var xb = (uint8[]) (uint8*) xp; xb.length = (int) xB;
          unowned var yb = (uint8[]) (uint8*) yp; yb.length = (int) yB;
          unowned var zb = (uint8[]) (uint8*) zp; zb.length = (int) zB;
          x.to_buffer (ExternalFormat.USG, xb);
          y.to_buffer (ExternalFormat.USG, yb);
          z.to_buffer (ExternalFormat.USG, zb);
          return (owned) ar;
        }

      [CCode (cname = "gcry_mpi_point_set")]
      public void @set (Scalar x, Scalar y, Scalar z);

      public Point.unpack (uint8[] buffer) throws Krypt.Error
        {

          this ();
          void* xp, yp, zp;
          uint xB, yB, zB;

          PointPack.unpack (buffer, out xp, out xB, out yp, out yB, out zp, out zB);

          unowned var xb = (uint8[]) (uint8*) xp; xb.length = (int) xB;
          unowned var yb = (uint8[]) (uint8*) yp; yb.length = (int) yB;
          unowned var zb = (uint8[]) (uint8*) zp; zb.length = (int) zB;
          var x = Scalar.parse (ExternalFormat.USG, xb);
          var y = Scalar.parse (ExternalFormat.USG, yb);
          var z = Scalar.parse (ExternalFormat.USG, zb);
          @set (x, y, z);
        }
    }
}