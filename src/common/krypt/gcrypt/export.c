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
#pragma once
#include <gcrypt.h>
#include <glib-object.h>

G_BEGIN_DECLS

  #define GCRYPT_API_PACKED_OVERHEAD (sizeof (guint16) * 3)

  static __inline gpointer gcrypt_point_pack_pack (gcry_mpi_t x, gcry_mpi_t y, gcry_mpi_t z, guint* buflen, gpointer* xp, guint* xB, gpointer* yp, guint* yB, gpointer* zp, guint* zB)
    {

      g_return_val_if_fail (x != NULL, NULL);
      g_return_val_if_fail (y != NULL, NULL);
      g_return_val_if_fail (z != NULL, NULL);

      guint xb, yb, zb, bytes;
      gpointer xr, yr, zr, buffer;

      bytes = sizeof (guint16) * 3;
      xr = G_STRUCT_MEMBER_P (NULL, bytes); bytes += (*xB = (((xb = gcry_mpi_get_nbits (x)) + 7) >> 3));
      yr = G_STRUCT_MEMBER_P (NULL, bytes); bytes += (*yB = (((yb = gcry_mpi_get_nbits (y)) + 7) >> 3));
      zr = G_STRUCT_MEMBER_P (NULL, bytes); bytes += (*zB = (((zb = gcry_mpi_get_nbits (z)) + 7) >> 3));

      buffer = g_malloc (bytes);
      *xp = G_STRUCT_MEMBER_P (buffer, (guintptr) xr); ((guint16*) buffer) [0] = GUINT16_TO_BE (xb);
      *yp = G_STRUCT_MEMBER_P (buffer, (guintptr) yr); ((guint16*) buffer) [1] = GUINT16_TO_BE (yb);
      *zp = G_STRUCT_MEMBER_P (buffer, (guintptr) zr); ((guint16*) buffer) [2] = GUINT16_TO_BE (zb);

    return (*buflen = bytes, buffer);
    }

  static __inline gboolean gcrypt_point_pack_unpack (gpointer buffer, gsize buflen, gpointer* xp, guint* xB, gpointer* yp, guint* yB, gpointer* zp, guint* zB)
    {

      g_return_val_if_fail (buffer != NULL, FALSE);
      g_return_val_if_fail (buflen >= 3 * sizeof (guint16), FALSE);
      guint xb, yb, zb, bytes;

      bytes = 3 * sizeof (guint16);
      *xp = G_STRUCT_MEMBER_P (buffer, bytes); bytes += (*xB = ((xb = GUINT16_FROM_BE (((guint16*) buffer) [0])) + 7) >> 3);
      *yp = G_STRUCT_MEMBER_P (buffer, bytes); bytes += (*yB = ((yb = GUINT16_FROM_BE (((guint16*) buffer) [1])) + 7) >> 3);
      *zp = G_STRUCT_MEMBER_P (buffer, bytes); bytes += (*zB = ((zb = GUINT16_FROM_BE (((guint16*) buffer) [2])) + 7) >> 3);

    return (({ g_return_val_if_fail (buflen == bytes, FALSE); }), TRUE);
    }

  G_STATIC_ASSERT (NULL != gcrypt_point_pack_pack && NULL != gcrypt_point_pack_unpack);

G_END_DECLS