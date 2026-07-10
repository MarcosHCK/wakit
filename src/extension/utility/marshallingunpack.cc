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
#include <glib/gi18n-lib.h>
#include <extension/utility/marshalling.h>

static inline GPtrArray* _container_unpack (JSCContext* context, GVariant* variant);
static inline JSCValue* _typearray_string (JSCContext* context, GVariant* variant);
static inline JSCValue* _typearray_unpack (JSCContext* context, GVariant* variant, JSCTypedArrayType type);
#define _g_variant_unref0(var) ((NULL == var) ? NULL : (var = (g_variant_unref (var), nullptr)))

JSCValue* wakit_marshalling_variant_to_jsc_value (JSCContext* context, GVariant* variant)
{

  g_return_val_if_fail (NULL != variant, NULL);
  g_return_val_if_fail (JSC_IS_CONTEXT (context), NULL);

  GVariant* take = NULL;
  const gchar* vtype = NULL;

# define push_(...) (G_GNUC_EXTENSION ({ \
 ; \
  _g_variant_unref0 (take); \
  variant = take = ((__VA_ARGS__)); }))

# define return_(...) (G_GNUC_EXTENSION ({ \
 ; \
  _g_variant_unref0 (take); \
  return ((__VA_ARGS__)); }))

  do { switch ((vtype = g_variant_get_type_string (variant)) [0])
    {

    case '(': G_GNUC_FALLTHROUGH;
    case '{':
      {

        auto array = _container_unpack (context, variant);
        auto value = jsc_value_new_array_from_garray (context, array);

        return_ (g_ptr_array_unref (array), value);
      }

    case 'a':
      {

        const auto super = g_variant_get_type (variant);
        const auto element = g_variant_type_element (super);

        switch (g_variant_type_peek_string (element) [0])
          {

          case 'd': return_ (_typearray_unpack (context, variant, JSC_TYPED_ARRAY_FLOAT64));
          case 'h': G_GNUC_FALLTHROUGH;
          case 'i': return_ (_typearray_unpack (context, variant, JSC_TYPED_ARRAY_INT32));
          case 'n': return_ (_typearray_unpack (context, variant, JSC_TYPED_ARRAY_INT16));
          case 'q': return_ (_typearray_unpack (context, variant, JSC_TYPED_ARRAY_UINT16));
          case 't': return_ (_typearray_unpack (context, variant, JSC_TYPED_ARRAY_UINT64));
          case 'u': return_ (_typearray_unpack (context, variant, JSC_TYPED_ARRAY_UINT32));
          case 'y': return_ (_typearray_string (context, variant));
          case 'x': return_ (_typearray_unpack (context, variant, JSC_TYPED_ARRAY_INT64));

          default: { auto array = _container_unpack (context, variant);
                     auto value = jsc_value_new_array_from_garray (context, array);
            return_ (g_ptr_array_unref (array), value); }
      } }

    case 'b': return_ (jsc_value_new_boolean (context, g_variant_get_boolean (variant)));
    case 'd': return_ (jsc_value_new_number (context, (double) g_variant_get_double (variant)));
    case 'h': return_ (jsc_value_new_number (context, (double) g_variant_get_handle (variant)));
    case 'i': return_ (jsc_value_new_number (context, (double) g_variant_get_int32 (variant)));

    case 'm':
      {

        GVariant* next;

        if (nullptr != (next = g_variant_get_maybe (variant)))

          { push_ (next); continue; }
        else
          { return_ (jsc_value_new_null (context)); }
      }

    case 'n': return_ (jsc_value_new_number (context, (double) g_variant_get_int16 (variant)));
    case 'q': return_ (jsc_value_new_number (context, (double) g_variant_get_uint16 (variant)));
    case 's': G_GNUC_FALLTHROUGH;
    case 'o': G_GNUC_FALLTHROUGH;
    case 'g': return_ (jsc_value_new_string (context, g_variant_get_string (variant, NULL)));
    case 't': return_ (jsc_value_new_number (context, (double) g_variant_get_uint64 (variant)));
    case 'u': return_ (jsc_value_new_number (context, (double) g_variant_get_uint32 (variant)));

    case 'v':
      {
        push_ (g_variant_get_variant (variant));
        continue;
      }
# undef push_

    case 'x': return_ (jsc_value_new_number (context, (double) g_variant_get_int64 (variant)));
    case 'y': return_ (jsc_value_new_number (context, (double) g_variant_get_byte (variant)));
# undef return_

    default:
      g_error ("unknown variant type '%s', fix this!", g_variant_get_type_string (variant));
    }
  break; } while (TRUE);
}

static GPtrArray* _container_unpack (JSCContext* context, GVariant* variant)
{

  auto array = g_ptr_array_sized_new (g_variant_n_children (variant));
  auto child = (GVariant*) nullptr;
  auto iter = GVariantIter { 0 };

  g_ptr_array_set_free_func (array, g_object_unref);

  for (g_variant_iter_init (&iter, variant); nullptr != (child = g_variant_iter_next_value (&iter));)
    {

      g_ptr_array_add (array, wakit_marshalling_variant_to_jsc_value (context, child));
      g_variant_unref (child);
    }
return array;
}

static inline JSCValue* _typearray_string (JSCContext* context, GVariant* variant)
{

  auto bytes = g_variant_get_data_as_bytes (variant);
  auto value = jsc_value_new_string_from_bytes (context, bytes);

return (g_bytes_unref (bytes), value);
}

static inline JSCValue* _typearray_unpack (JSCContext* context, GVariant* variant, JSCTypedArrayType type)
{

  auto length = g_variant_n_children (variant);
  auto array = jsc_value_new_typed_array (context, type, length);

  g_assert (jsc_value_typed_array_get_size (array) == g_variant_get_size (variant));

return (g_variant_store (variant, jsc_value_typed_array_get_data (array, NULL)), array);
}
