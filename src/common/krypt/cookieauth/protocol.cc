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
#include <common/hex/wakit-common-hex.h>
#include <common/krypt/cookieauth/internal.h>
#include <common/krypt/cookieauth/protocol.h>
#include <memory>

struct _WakitKryptCookieAuthProtocolComponentPrivate
{

  gchar* auth_scope;
  gsize auth_scope_length;
  gchar* master_key;
  gsize master_key_length;
};

enum
{
  prop_0,
  prop_auth_scope,
  prop_master_key,
  prop_number,
};

#define _g_free0(var) ((NULL == var) ? NULL : (var = (g_free (var), nullptr)))
static GParamSpec* properties [prop_number] = { 0 };

G_DEFINE_ABSTRACT_TYPE_WITH_PRIVATE (WakitKryptCookieAuthProtocolComponent, wakit_krypt_cookie_auth_protocol_component, G_TYPE_OBJECT)
#define parent_ wakit_krypt_cookie_auth_protocol_component_parent_class

static void wakit_krypt_cookie_auth_protocol_component_class_finalize (GObject* pself)
{

  auto priv = ((WakitKryptCookieAuthProtocolComponent*) pself)->priv;

  _g_free0 (priv->auth_scope);
  _g_free0 (priv->master_key);

return G_OBJECT_CLASS (parent_)->dispose (pself);
}

static void wakit_krypt_cookie_auth_protocol_component_class_get_property (GObject* pself, guint property_id, GValue* value, GParamSpec* pspec)
{

  switch (auto priv = ((WakitKryptCookieAuthProtocolComponent*) pself)->priv; property_id)
    {

    case prop_auth_scope: g_value_set_string (value, priv->auth_scope);
      break;

    case prop_master_key: g_value_set_string (value, priv->master_key);
      break;

    default: G_OBJECT_WARN_INVALID_PROPERTY_ID (pself, property_id, pspec);
      break;
    }
}

static void wakit_krypt_cookie_auth_protocol_component_class_set_property (GObject* pself, guint property_id, const GValue* value, GParamSpec* pspec)
{

  switch (auto priv = ((WakitKryptCookieAuthProtocolComponent*) pself)->priv; property_id)
    {

    case prop_auth_scope: g_set_str (&priv->auth_scope, g_value_get_string (value));
                          priv->auth_scope_length = NULL == priv->auth_scope ? 0 : strlen (priv->auth_scope);
      break;

    case prop_master_key:
      {

        auto str = g_value_get_string (value);
        auto len = NULL == str ? 0 : strlen (str);

        _g_free0 (priv->master_key);
        g_return_if_fail (NULL == str || len == WAKIT_KRYPT_COOKIE_AUTH_STRING_LENGTH);

        priv->master_key = NULL == str ? nullptr : g_strndup (str, len);
        priv->master_key_length = len;
    } break;

    default: G_OBJECT_WARN_INVALID_PROPERTY_ID (pself, property_id, pspec);
      break;
    }
}

static void wakit_krypt_cookie_auth_protocol_component_class_init (WakitKryptCookieAuthProtocolComponentClass* klass)
{

  G_OBJECT_CLASS (klass)->finalize = wakit_krypt_cookie_auth_protocol_component_class_finalize;
  G_OBJECT_CLASS (klass)->get_property = wakit_krypt_cookie_auth_protocol_component_class_get_property;
  G_OBJECT_CLASS (klass)->set_property = wakit_krypt_cookie_auth_protocol_component_class_set_property;

  properties [prop_auth_scope] = g_param_spec_string ("auth-scope", "auth-scope", "auth-scope", NULL,
    (GParamFlags) (G_PARAM_CONSTRUCT | G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS));

  properties [prop_master_key] = g_param_spec_string ("master-key", "master-key", "master-key", NULL,
    (GParamFlags) (G_PARAM_CONSTRUCT | G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS));

  g_object_class_install_properties (G_OBJECT_CLASS (klass), prop_number, properties);
}

static void wakit_krypt_cookie_auth_protocol_component_init (WakitKryptCookieAuthProtocolComponent* self)
{
  self->priv = (WakitKryptCookieAuthProtocolComponentPrivate*) wakit_krypt_cookie_auth_protocol_component_get_instance_private (self);
}

[[gnu::always_inline]]
static inline void _make_session_key (WakitKryptCookieAuthProtocolComponentPrivate* priv,
                                      guint64 counter,
                                      guint8 buffer [WAKIT_KRYPT_COOKIE_AUTH_BYTE_LENGTH],
                                      GError** error)
{

  gcry_error_t code;

  auto salt = (guint8*) g_malloc (priv->auth_scope_length + sizeof (counter));

  std::uninitialized_copy_n ((guint8*) &counter, sizeof (counter),
  std::uninitialized_copy_n (priv->auth_scope, priv->auth_scope_length, salt));

  code = gcry_kdf_derive (priv->master_key, priv->master_key_length,
                          WAKIT_KRYPT_COOKIE_AUTH_KDF_ALGO,
                          WAKIT_KRYPT_COOKIE_AUTH_KDF_SUBALGO,
                          salt, priv->auth_scope_length + sizeof (counter),
                          WAKIT_KRYPT_COOKIE_AUTH_KDF_ITERATIONS,
                          WAKIT_KRYPT_COOKIE_AUTH_BYTE_LENGTH,
                          buffer);

  if (g_free (salt); G_UNLIKELY (0 != error))
    return wakit_krypt_gcrypt_error_propagate (error, code);
}

WakitKryptGCryptCipher* wakit_krypt_cookie_auth_protocol_component_open_session_cipher (WakitKryptCookieAuthProtocolComponent* component,
                                                                                          guint64 counter,
                                                                                          WakitKryptCookieAuthIV iv,
                                                                                          GError** error)
{

  g_return_val_if_fail (WAKIT_KRYPT_COOKIE_AUTH_IS_PROTOCOL_COMPONENT (component), NULL);
  g_return_val_if_fail (error == NULL || *error == NULL, NULL);
  WakitKryptCookieAuthProtocolComponentPrivate* priv = component->priv;
  WakitKryptGCryptCipher* cph;

  constexpr auto cipher_algo = WAKIT_KRYPT_COOKIE_AUTH_CIPHER_ALGO;
  constexpr auto cipher_mode = WAKIT_KRYPT_COOKIE_AUTH_CIPHER_MODE;
  constexpr auto flags = GCRY_CIPHER_SECURE;

  if (gcry_error_t code = gcry_cipher_open (&cph, cipher_algo, cipher_mode, flags); 0 != code)
    return (wakit_krypt_gcrypt_error_propagate (error, code), nullptr);

  if (gcry_error_t code = gcry_cipher_setiv (cph, iv, WAKIT_KRYPT_COOKIE_AUTH_CIPHER_IV_BYTE_LENGTH); 0 != code)
    { gcry_cipher_close (cph);
      return (wakit_krypt_gcrypt_error_propagate (error, code), nullptr); }

  guint8 session_key [WAKIT_KRYPT_COOKIE_AUTH_BYTE_LENGTH];

  if (GError* tmperr = NULL; (_make_session_key (priv, counter, session_key, &tmperr), G_UNLIKELY (NULL != tmperr)))
    { gcry_cipher_close (cph);
      return (g_propagate_error (error, tmperr), nullptr); }

  if (gcry_error_t code = gcry_cipher_setkey (cph, session_key, WAKIT_KRYPT_COOKIE_AUTH_BYTE_LENGTH); 0 != code)
    { gcry_cipher_close (cph);
      return (wakit_krypt_gcrypt_error_propagate (error, code), nullptr); }

return cph;
}