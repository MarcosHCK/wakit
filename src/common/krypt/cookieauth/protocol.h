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

#define WAKIT_KRYPT_COOKIE_AUTH_BIT_LENGTH 256
#define WAKIT_KRYPT_COOKIE_AUTH_BYTE_LENGTH (WAKIT_KRYPT_COOKIE_AUTH_BIT_LENGTH >> 3)
/* two characters per byte */
#define WAKIT_KRYPT_COOKIE_AUTH_STRING_LENGTH (WAKIT_KRYPT_COOKIE_AUTH_BIT_LENGTH >> 2)

#define WAKIT_KRYPT_COOKIE_AUTH_TYPE_PROTOCOL_COMPONENT (wakit_krypt_cookie_auth_protocol_component_get_type ())
#define WAKIT_KRYPT_COOKIE_AUTH_PROTOCOL_COMPONENT(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), WAKIT_KRYPT_COOKIE_AUTH_TYPE_PROTOCOL_COMPONENT, WakitKryptCookieAuthProtocolComponent))
#define WAKIT_KRYPT_COOKIE_AUTH_IS_PROTOCOL_COMPONENT(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), WAKIT_KRYPT_COOKIE_AUTH_TYPE_PROTOCOL_COMPONENT))
typedef struct _WakitKryptCookieAuthProtocolComponent WakitKryptCookieAuthProtocolComponent;
typedef struct _WakitKryptCookieAuthProtocolComponentPrivate WakitKryptCookieAuthProtocolComponentPrivate;

#define WAKIT_KRYPT_COOKIE_AUTH_PROTOCOL_COMPONENT_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), WAKIT_KRYPT_COOKIE_AUTH_TYPE_PROTOCOL_COMPONENT, WakitKryptCookieAuthProtocolComponentClass))
#define WAKIT_KRYPT_COOKIE_AUTH_IS_PROTOCOL_COMPONENT_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), WAKIT_KRYPT_COOKIE_AUTH_TYPE_PROTOCOL_COMPONENT))
#define WAKIT_KRYPT_COOKIE_AUTH_PROTOCOL_COMPONENT_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), WAKIT_KRYPT_COOKIE_AUTH_TYPE_PROTOCOL_COMPONENT, WakitKryptCookieAuthProtocolComponentClass))
typedef struct _WakitKryptCookieAuthProtocolComponentClass WakitKryptCookieAuthProtocolComponentClass;

G_BEGIN_DECLS

  struct _WakitKryptCookieAuthProtocolComponent
    {

      GObject parent;
      WakitKryptCookieAuthProtocolComponentPrivate* priv;
    };

  struct _WakitKryptCookieAuthProtocolComponentClass
    {

      GObjectClass parent;
    };

  GType wakit_krypt_cookie_auth_protocol_component_get_type (void) G_GNUC_CONST;

G_END_DECLS