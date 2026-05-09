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
#include <config.h>
#include <common/krypt/gcrypt/gcryptapi.h>

#define WAKIT_KRYPT_GCRYPT_ERROR (wakit_krypt_gcrypt_error_quark ())

G_LOCK_DEFINE_STATIC (gcry_strerror);

WakitKryptGCryptCipher* wakit_krypt_gcrypt_cipher_new (int algo, int mode, int flags, GError** error)
{

  WakitKryptGCryptCipher* cph;

  if (gcry_error_t code = gcry_cipher_open (&cph, algo, mode, flags); G_UNLIKELY (0 != code))
    return (wakit_krypt_gcrypt_error_propagate (error, code), nullptr);

return cph;
}

GError* wakit_krypt_gcrypt_error_code_to_error (gcry_error_t code)
{

  G_LOCK (gcry_strerror);

  GError* error = g_error_new (WAKIT_KRYPT_GCRYPT_ERROR, (int) code, "%s / %s", gcry_strerror (code),
                                                                                gcry_strsource (code));

return (G_UNLOCK (gcry_strerror), error);
}

gchar* wakit_krypt_gcrypt_error_code_to_string (gcry_error_t code)
{

  G_LOCK (gcry_strerror);
  gchar* message = g_strdup_printf ("%s / %s", gcry_strerror (code),
                                               gcry_strsource (code));

return (G_UNLOCK (gcry_strerror), message);
}