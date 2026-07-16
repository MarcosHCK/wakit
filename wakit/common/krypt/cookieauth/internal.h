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
#include <glib-object.h>
#include <wakit/common/krypt/cookieauth/protocol.h>
#include <wakit/common/krypt/gcrypt/gcryptapi.h>

#define WAKIT_KRYPT_COOKIE_AUTH_CHALLENGE_BYTE_LENGTH WAKIT_KRYPT_COOKIE_AUTH_BYTE_LENGTH
#define WAKIT_KRYPT_COOKIE_AUTH_CIPHER_ALGO GCRY_CIPHER_AES256
#define WAKIT_KRYPT_COOKIE_AUTH_CIPHER_MODE GCRY_CIPHER_MODE_CTR
#define WAKIT_KRYPT_COOKIE_AUTH_CIPHER_IV_BYTE_LENGTH 16
#define WAKIT_KRYPT_COOKIE_AUTH_KDF_ALGO GCRY_KDF_PBKDF2
#define WAKIT_KRYPT_COOKIE_AUTH_KDF_ITERATIONS 1024
#define WAKIT_KRYPT_COOKIE_AUTH_KDF_SUBALGO GCRY_MD_SHA256

typedef guint8 WakitKryptCookieAuthIV [WAKIT_KRYPT_COOKIE_AUTH_CIPHER_IV_BYTE_LENGTH];

G_BEGIN_DECLS

  WakitKryptGCryptCipher* wakit_krypt_cookie_auth_protocol_component_open_session_cipher (WakitKryptCookieAuthProtocolComponent* component,
                                                                                          guint64 counter,
                                                                                          WakitKryptCookieAuthIV iv,
                                                                                          GError** error);

G_END_DECLS