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
#include <common/ffi/function.h>
#include <tests/testing.h>
using namespace testing;

int main (int argc, char* argv[])
{

  g_test_init (&argc, &argv, NULL);

  g_test_add_ (TESTPATHROOT "/new", []
    {

      ffi::function<void, const char*, int, int&> func (g_print);
      (void) func;
    });

  g_test_add_ (TESTPATHROOT "/void/works", []
    {

      ffi::function<void, const char*, int, int&> func (g_print);

      int tmp = 2;
      func.get_codeloc () ("prints %i %p\n", 1, tmp);
    });

  g_test_add_ (TESTPATHROOT "/return/works", []
    {

      ffi::function<gchar*, const char*, int, int&> func (g_strdup_printf);
      std::function<gchar* (const char*, int, int&)> func2 (g_strdup_printf);

      int value1 = g_test_rand_int ();
      int value2 = g_test_rand_int ();

      gchar* result1 = func.get_codeloc () ("prints %i %p\n", value1, value2);
      gchar* result2 = func2 ("prints %i %p\n", value1, value2);

      g_assert_cmpstr (result1, ==, result2);
      g_free (result1); g_free (result2);
    });

  g_test_add_ (TESTPATHROOT "/return/works/reference", []
    {

      auto value = new int (g_test_rand_int ());

      ffi::function<int&> func ([=] -> int& { return *value; });
      std::function<int& ()> func2 ([=] -> int& { return *value; });

      int result2 = func2 ();
      int result1 = func.get_codeloc () ();

      g_assert_cmpint (result1, ==, result2);
      g_assert_cmpint (result1, ==, *value);
      delete value;
    });

return g_test_run ();
}