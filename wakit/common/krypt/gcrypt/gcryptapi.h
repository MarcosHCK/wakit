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

typedef struct gcry_cipher_handle WakitKryptGCryptCipher;

G_BEGIN_DECLS

  WakitKryptGCryptCipher* wakit_krypt_gcrypt_cipher_new (int algo, int mode, int flags, GError** error);

  GQuark wakit_krypt_gcrypt_error_quark (void) G_GNUC_CONST;

  GError* wakit_krypt_gcrypt_error_code_to_error (gcry_error_t code);
  gchar* wakit_krypt_gcrypt_error_code_to_string (gcry_error_t code);

  static __inline void wakit_krypt_gcrypt_error_propagate (GError** error, gcry_error_t code)
    {

    return g_propagate_error (error, wakit_krypt_gcrypt_error_code_to_error (code));
    }

G_END_DECLS