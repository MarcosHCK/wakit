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
#include <extension/utility/marshalling.h>
#include <tests/extension/testing.h>
#include <tests/testing.h>
using namespace testing;

static inline JSCValue* marshal (const JSCContainer& container, GVariant* variant)
{

  gchar* str;
  const GVariantType* vtype = g_variant_get_type (variant);

  g_test_message ("GVariantType %s", str = g_variant_type_dup_string (vtype));
  g_free (str);

  g_test_message ("GVariant %s", str = g_variant_print (variant, TRUE));
  g_free (str);

  auto value = wakit_marshalling_variant_to_jsc_value (container.get_context (), variant);

  g_test_message ("JSCValue %s", str = container.to_string (value));
  g_free (str);

return value;
}

int main (int argc, char* argv[])
{

  g_test_init (&argc, &argv, NULL);

  g_test_add_<JSCContainer> (TESTPATHROOT "/basic", [](const JSCContainer& container)
    {

      auto variant = g_test_rand_variant ("bdghinoqstuxy", 13, 10, 10);

      g_object_unref (marshal (container, variant));
      g_variant_unref (variant);
    });

  g_test_add_<JSCContainer> (TESTPATHROOT "/array_maybe_basic", [](const JSCContainer& container)
    {

      auto variant = g_test_rand_variant ("abdghimnoqstuxy", 13, 10, 10);

      g_object_unref (marshal (container, variant));
      g_variant_unref (variant);
    });

  g_test_add_<JSCContainer> (TESTPATHROOT "/full", [](const JSCContainer& container)
    {

      auto variant = g_test_rand_variant ("({abdghimnoqstuvxy", 13, 10, 10);

      g_object_unref (marshal (container, variant));
      g_variant_unref (variant);
    });

return g_test_run ();
}