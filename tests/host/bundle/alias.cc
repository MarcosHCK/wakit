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
#include <host/bundle/wakit-host-bundle.h>
#include <tests/testing.h>
using namespace testing;

int main (int argc, char* argv [])
{

  g_test_init (&argc, &argv, NULL);

  g_test_add_ (TESTPATHROOT "/absolute/not", []
    {

      auto pattern = g_test_rand_string (20, 10, nullptr);
      auto replacement = g_test_rand_string (20, 10, nullptr, pattern);

      auto alias = wakit_bundle_absolute_alias_new (pattern.c_str (), replacement.c_str ());

      g_assert_false (wakit_bundle_alias_matches ((WakitBundleAlias*) alias, replacement.c_str (), replacement.length ()));
      g_object_unref (alias);
    });

  g_test_add_ (TESTPATHROOT "/absolute/yes", []
    {

      auto pattern = g_test_rand_string (20, 10, nullptr);
      auto replacement = g_test_rand_string (20, 10, nullptr, pattern);

      auto alias = wakit_bundle_absolute_alias_new (pattern.c_str (), replacement.c_str ());

      g_assert_true (wakit_bundle_alias_matches ((WakitBundleAlias*) alias, pattern.c_str (), pattern.length ()));

      auto done = wakit_bundle_alias_replace ((WakitBundleAlias*) alias, pattern.c_str (), pattern.length ());

      g_assert_cmpstring (done, ==, replacement.c_str ());
      g_free (done);

      g_object_unref (alias);
    });

  g_test_add_ (TESTPATHROOT "/regex/not", []
    {

      auto pattern = g_test_rand_string (20, 10, "abcdefghijklmnopqrstuvwxyz");
      auto replacement = g_test_rand_string (20, 10, "abcdefghijklmnopqrstuvwxyz", pattern);

      auto tmperr = (GError*) nullptr;
      auto regex = g_regex_new ("[0-9]", G_REGEX_OPTIMIZE, G_REGEX_MATCH_DEFAULT, &tmperr);
      g_assert_no_error (tmperr);

      auto alias = wakit_bundle_regex_alias_new_literal (regex, replacement.c_str ());
      g_regex_unref (regex);

      g_assert_false (wakit_bundle_alias_matches ((WakitBundleAlias*) alias, pattern.c_str (), pattern.length ()));
      g_object_unref (alias);
    });

  g_test_add_ (TESTPATHROOT "/regex/yes", []
    {

      auto pattern = g_test_rand_string (20, 10, "abcdefghijklmnopqrstuvwxyz");
      auto replacement = g_test_rand_string (20, 10, "abcdefghijklmnopqrstuvwxyz", pattern);
      auto excepted = replacement + pattern;

      auto tmperr = (GError*) nullptr;
      auto regex = g_regex_new ("[0-9]", G_REGEX_OPTIMIZE, G_REGEX_MATCH_DEFAULT, &tmperr);
      g_assert_no_error (tmperr);

      auto alias = wakit_bundle_regex_alias_new_literal (regex, replacement.c_str ());
      g_regex_unref (regex);

      pattern = "0" + pattern;
      g_assert_true (wakit_bundle_alias_matches ((WakitBundleAlias*) alias, pattern.c_str (), pattern.length ()));

      auto done = wakit_bundle_alias_replace ((WakitBundleAlias*) alias, pattern.c_str (), pattern.length ());

      g_assert_cmpstring (done, ==, excepted.c_str ());
      g_free (done);

      g_object_unref (alias);
    });

  g_test_add_ (TESTPATHROOT "/verbatim", []
    {

      auto pattern = g_test_rand_string (20, 10, nullptr);

      auto alias = wakit_bundle_verbatim_alias_new ();

      g_assert_true (wakit_bundle_alias_matches ((WakitBundleAlias*) alias, pattern.c_str (), pattern.length ()));

      auto done = wakit_bundle_alias_replace ((WakitBundleAlias*) alias, pattern.c_str (), pattern.length ());

      g_assert_cmpstring (done, ==, pattern.c_str ());
      g_free (done);

      g_object_unref (alias);
    });

  g_test_add_ (TESTPATHROOT "/realcase", []
    {

      auto pattern = std::string ("/");
      auto replacement = std::string ("/index.html");

      auto tmperr = (GError*) nullptr;
      auto regex = g_regex_new ("^/$", G_REGEX_OPTIMIZE, G_REGEX_MATCH_DEFAULT, &tmperr);
      g_assert_no_error (tmperr);

      auto alias = wakit_bundle_regex_alias_new_literal (regex, replacement.c_str ());
      g_regex_unref (regex);

      g_assert_true (wakit_bundle_alias_matches ((WakitBundleAlias*) alias, pattern.c_str (), pattern.length ()));

      auto done = wakit_bundle_alias_replace ((WakitBundleAlias*) alias, pattern.c_str (), pattern.length ());

      g_assert_cmpstring (done, ==, replacement.c_str ());
      g_free (done);

      g_object_unref (alias);
    });

return g_test_run ();
}