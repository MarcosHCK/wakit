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
#include <common/boxing.h>
#include <tests/common/krypt/cookieauth/providers.h>
#include <tests/testing.h>
using namespace boxing;
using namespace testing;

class tod_provider
{

  auth_provider _provider1;
  auth_provider _provider2;
};

int main (int argc, char* argv[])
{

  g_test_init (&argc, &argv, NULL);

  g_test_add_<auth_provider> (TESTPATHROOT "/new", [](const auth_provider& provider)
    {
    });

  g_test_add_<auth_provider> (TESTPATHROOT "/good", [](const auth_provider& provider)
    {

      GError* tmperr = NULL;

      auto challenge = wakit_krypt_cookie_auth_server_next_challenge (provider.get_server ());
      auto response = wakit_krypt_cookie_auth_client_respond_challenge (provider.get_client (), challenge, &tmperr);
      g_assert_no_error (tmperr);

      auto good = wakit_krypt_cookie_auth_server_check_challenge (provider.get_server (), challenge, response, &tmperr);
      g_assert_no_error (tmperr);

      g_assert_true (good);
    });

  g_test_add_<std::pair<auth_provider, auth_provider>> (TESTPATHROOT "/wrong/bad_responder", [](const std::pair<auth_provider, auth_provider>& providers)
    {

      auto& [ provider1, provider2 ] = providers;
      GError* tmperr = NULL;

      auto challenge = wakit_krypt_cookie_auth_server_next_challenge (provider1.get_server ());
      auto response = wakit_krypt_cookie_auth_client_respond_challenge (provider2.get_client (), challenge, &tmperr);
      g_assert_no_error (tmperr);

      auto good = wakit_krypt_cookie_auth_server_check_challenge (provider1.get_server (), challenge, response, &tmperr);
      g_assert_no_error (tmperr);

      g_assert_false (good);
    });

  g_test_add_<std::pair<auth_provider, auth_provider>> (TESTPATHROOT "/wrong/bad_checker", [](const std::pair<auth_provider, auth_provider>& providers)
    {

      auto& [ provider1, provider2 ] = providers;
      GError* tmperr = NULL;

      auto challenge = wakit_krypt_cookie_auth_server_next_challenge (provider1.get_server ());
      auto response = wakit_krypt_cookie_auth_client_respond_challenge (provider1.get_client (), challenge, &tmperr);
      g_assert_no_error (tmperr);

      auto good = wakit_krypt_cookie_auth_server_check_challenge (provider2.get_server (), challenge, response, &tmperr);
      g_assert_no_error (tmperr);

      g_assert_false (good);
    });

return g_test_run ();
}