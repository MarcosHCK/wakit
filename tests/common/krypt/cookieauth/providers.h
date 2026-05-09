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
#include <common/boxing.h>
#include <common/krypt/cookieauth/wakit-common-krypt-cookieauth.h>

class key_provider
{

  boxing::destructible_box<WakitKryptCookieAuthCookie, wakit_krypt_cookie_auth_cookie_free> _cookie;
public:

  inline key_provider () noexcept: _cookie (wakit_krypt_cookie_auth_cookie_new_random ())
    { }

  inline constexpr WakitKryptCookieAuthCookie* get_cookie () const noexcept
    { return *_cookie; }
};

class client_provider: public virtual key_provider
{

  boxing::object<WakitKryptCookieAuthClient> _client;
public:

  inline client_provider (): key_provider (), _client ()
    {

      boxing::freeable<gchar> _key;

      _key = wakit_krypt_cookie_auth_cookie_to_string (get_cookie ());
      _client = wakit_krypt_cookie_auth_client_new (*_key, nullptr);
    }

  inline WakitKryptCookieAuthClient* get_client () const noexcept
    { return *_client; }
};

class server_provider: public virtual key_provider
{

  boxing::object<WakitKryptCookieAuthServer> _server;
public:

  inline server_provider () noexcept: key_provider (), _server ()
    {

      boxing::freeable<gchar> _key;

      _key = wakit_krypt_cookie_auth_cookie_to_string (get_cookie ());
      _server = wakit_krypt_cookie_auth_server_new (*_key, nullptr);
    }

  inline WakitKryptCookieAuthServer* get_server () const noexcept
    { return *_server; }
};

class auth_provider: public virtual client_provider, public virtual key_provider, public virtual server_provider
{

public:

  inline auth_provider (): key_provider (), client_provider (), server_provider ()
    { }
};