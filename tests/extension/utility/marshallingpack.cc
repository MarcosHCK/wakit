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

static inline JSCValue* marshal_in (const JSCContainer& container, GVariant* variant)
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

static inline GVariant* marshal (const testing::JSCContainer& container, const GVariantType* vtype, JSCValue* value)
{

  GError* error = nullptr;
  gchar* str;

  g_test_message ("JSCValue %s", str = container.to_string (value));
  g_free (str);

  g_test_message ("GVariantType %s", str = g_variant_type_dup_string (vtype));
  g_free (str);

  auto variant = wakit_marshalling_jsc_value_to_variant (container.get_context (), vtype, value, &error);

  g_assert_no_error (error);

  g_test_message ("GVariant %s", str = g_variant_print (variant, TRUE));
  g_free (str);

return g_variant_ref_sink (variant);
}

int main (int argc, char* argv[])
{

  g_test_init (&argc, &argv, NULL);

  g_test_add_<JSCContainer> (TESTPATHROOT "/simple", [](const JSCContainer& container)
    {

      auto value = jsc_context_evaluate (container.get_context (),
        "({ 'first': [ 1, 2 ], 'second': [ [], 2 ] })", -1);

      g_variant_unref (marshal (container, G_VARIANT_TYPE ("a{s(ii)}"), value));
      g_object_unref (value);
    });

  g_test_add_<JSCContainer> (TESTPATHROOT "/basic", [](const JSCContainer& container)
    {

      auto variant_type = g_test_rand_variant_type ("bdghinoqstuxy", 13, 10, 10);
      auto variant = g_test_rand_variant (variant_type, 10, 10);

      auto value = marshal_in (container, variant);

      auto variant2 = marshal (container, variant_type, value);
      g_object_unref (value);

      g_assert_cmpvariant (variant, variant2);

      g_variant_unref (variant);
      g_variant_unref (variant2);
    });

  g_test_add_<JSCContainer> (TESTPATHROOT "/dict_entry_tuple_maybe_basic", [](const JSCContainer& container)
    {

      auto variant_type = g_test_rand_variant_type ("({bdghimnoqstuxy", 13, 10, 10);
      auto variant = g_test_rand_variant (variant_type, 10, 10);

      auto value = marshal_in (container, variant);

      auto variant2 = marshal (container, variant_type, value);
      g_object_unref (value);

      g_assert_cmpvariant (variant, variant2);

      g_variant_unref (variant);
      g_variant_unref (variant2);
    });

  g_test_add_<JSCContainer> (TESTPATHROOT "/full", [](const JSCContainer& container)
    {

      auto variant_type = g_test_rand_variant_type ("({abdghimnoqstuxy", 13, 10, 10);
      auto variant = g_test_rand_variant (variant_type, 10, 10);

      auto value = marshal_in (container, variant);

      auto variant2 = marshal (container, variant_type, value);
      g_object_unref (value);

      g_assert_cmpvariant (variant, variant2);

      g_variant_unref (variant);
      g_variant_unref (variant2);
    });

return g_test_run ();
}