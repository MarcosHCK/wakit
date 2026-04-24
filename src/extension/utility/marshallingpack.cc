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
#include <common/bits.h>
#include <extension/utility/marshalling.h>

G_DEFINE_QUARK (wakit-marshalling-error-quark, wakit_marshalling_error)

[[gnu::always_inline]] static inline bool g_variant_type_is_numeric (const GVariantType* type)
{

  switch (g_variant_type_peek_string (type) [0])  
    {
    case 'b': G_GNUC_FALLTHROUGH;
    case 'd': G_GNUC_FALLTHROUGH;
    case 'h': G_GNUC_FALLTHROUGH;
    case 'i': G_GNUC_FALLTHROUGH;
    case 'n': G_GNUC_FALLTHROUGH;
    case 'q': G_GNUC_FALLTHROUGH;
    case 't': G_GNUC_FALLTHROUGH;
    case 'u': G_GNUC_FALLTHROUGH;
    case 'x': G_GNUC_FALLTHROUGH;
    case 'y': return true;
    }
return false;
}

static GVariant* _bytearray_pack (JSCContext* context, const GVariantType* vtype, JSCValue* string);
static GVariant* _dictionary_pack (JSCContext* context, const GVariantType* vtype, JSCValue* object, GError** error);
template<char _T>
static GVariant* _tuple_pack (JSCContext* context, const GVariantType* vtype, JSCValue* value, GError** error);
static GVariant* _typearray_pack (JSCContext* context, const GVariantType* child_type, JSCValue* value);
static GVariant* _valuearray_pack (JSCContext* context, const GVariantType* child_type, JSCValue* value, GError** error);

typedef const GVariantType* (*TypeIterInit) (const GVariantType* vtype);
typedef const GVariantType* (*TypeIterNext) (const GVariantType* vtype, const GVariantType* before);

template<TypeIterInit _iter_init,
         TypeIterNext _iter_next>
static GPtrArray* _valuearray_take (JSCContext* context, const GVariantType* child_type, JSCValue* value, GError** error);

GVariant* wakit_marshalling_jsc_value_to_variant (JSCContext* context, const GVariantType* vtype, JSCValue* value, GError** error)
{

  switch (auto vt = g_variant_type_peek_string (vtype) [0]; vt)
    {

    case '(': G_GNUC_FALLTHROUGH;
    case '{':
      {

        auto v_children = g_variant_type_n_items (vtype);
        auto j_children = (decltype (v_children)) 0;

        if (! jsc_value_is_array (value))
          
          return (g_set_error_literal (error, WAKIT_MARSHALLING_ERROR,
                                              WAKIT_MARSHALLING_ERROR_ARRAY_EXPECTED,
                    "tuple/dict-entry expansion needs an array argument"), nullptr);
        else
          {

            auto val = jsc_value_object_get_property (value, "length");
            auto vai = jsc_value_to_int32 (val);

            g_object_unref ((j_children = vai, val));
          }

        if (j_children == v_children)

          switch (vt) { case '(': return _tuple_pack<'('> (context, vtype, value, error);
                        case '{': return _tuple_pack<'{'> (context, vtype, value, error); }
        else
          return (g_set_error_literal (error, WAKIT_MARSHALLING_ERROR,
                                              WAKIT_MARSHALLING_ERROR_ARRAY_EXPECTED,
                  j_children < v_children ? "too few values" : "too many values"), nullptr);
      }

    case 'a':

      if (const auto child_type = g_variant_type_element (vtype); g_variant_type_is_numeric (child_type))
        {

          if (jsc_value_is_typed_array (value))
            return _typearray_pack (context, child_type, value);

          else if (jsc_value_is_array (value))
            return _valuearray_pack (context, child_type, value, error);

          else if (g_variant_type_equal (child_type, G_VARIANT_TYPE ("y")) && jsc_value_is_string (value))
            return _bytearray_pack (context, vtype, value);

          else if (gchar* str; true)

            return (g_set_error (error, WAKIT_MARSHALLING_ERROR,
                                        WAKIT_MARSHALLING_ERROR_ARRAY_EXPECTED,
                      "%s expansion needs an array-like value", str = g_variant_type_dup_string (child_type)),
                      g_free (str), nullptr);
        }
      else
        {

          if (jsc_value_is_array (value))
            return _valuearray_pack (context, child_type, value, error);

          else if (g_variant_type_is_subtype_of (child_type, G_VARIANT_TYPE_DICT_ENTRY) && jsc_value_is_object (value))
            return _dictionary_pack (context, vtype, value, error);

          else if (gchar* str; true)

            return (g_set_error (error, WAKIT_MARSHALLING_ERROR,
                                        WAKIT_MARSHALLING_ERROR_ARRAY_EXPECTED,
                        "%s expansion needs an array-like value", str = g_variant_type_dup_string (child_type)),
                        g_free (str), nullptr);
        }

    case 'b': return g_variant_new_boolean (jsc_value_to_boolean (value));
    case 'd': return g_variant_new_double ((gdouble) jsc_value_to_double (value));
    case 'g': return g_variant_new_signature (jsc_value_to_string (value));
    case 'h': return g_variant_new_handle ((gint32) jsc_value_to_int32 (value));
    case 'i': return g_variant_new_int32 ((gint32) jsc_value_to_int32 (value));

    case 'm':
      {

        auto child_type = g_variant_type_element (vtype);
        auto tmperr = (GError*) nullptr;

        if (NULL == value || jsc_value_is_null (value) || jsc_value_is_undefined (value))

          return g_variant_new_maybe (child_type, NULL);
        else

          if (auto variant = wakit_marshalling_jsc_value_to_variant (context, child_type, value, &tmperr); G_LIKELY (nullptr == tmperr))

            return g_variant_new_maybe (child_type, variant);
          else
            return (g_propagate_error (error, tmperr), nullptr);
      }

    case 'n': return g_variant_new_int16 ((gint16) jsc_value_to_int32 (value));
    case 'o': return g_variant_new_object_path (jsc_value_to_string (value));
    case 'q': return g_variant_new_uint16 ((guint16) jsc_value_to_int32 (value));
    case 's': return g_variant_new_take_string (jsc_value_to_string (value));
    case 't': return g_variant_new_uint64 ((guint64) jsc_value_to_double (value));
    case 'u': return g_variant_new_uint32 ((guint32) jsc_value_to_int32 (value));
    case 'x': return g_variant_new_int64 ((gint64) jsc_value_to_double (value));
    case 'y': return g_variant_new_byte ((guchar) jsc_value_to_int32 (value));

    default:
      g_error ("unknown variant type '%s', fix this!", g_variant_type_dup_string (vtype));
    }
}

static GVariant* _bytearray_pack (JSCContext* context, const GVariantType* vtype, JSCValue* string)
{

  auto bytes = jsc_value_to_string_as_bytes (string);
  auto variant = g_variant_new_from_bytes (vtype, bytes, false);

return (g_bytes_unref (bytes), variant);
}

extern unsigned char objectserializer_js [];
extern unsigned int objectserializer_js_len;

static GVariant* _dictionary_pack (JSCContext* context, const GVariantType* vtype, JSCValue* object, GError** error)
{

  auto jsc_class = wakit_object_serializer_get_class (context);
  auto instance = wakit_object_serializer_new (vtype);
  auto serializer = jsc_value_new_object (context, instance, jsc_class);

  JSCValue* args [2] { object, serializer };
  GVariant* variant = nullptr;

  auto module = jsc_context_evaluate_with_source_uri (context, (const char*) objectserializer_js, objectserializer_js_len,
    "code://marshalling/pack", 1);

  auto func = jsc_value_object_get_property (module, "serialize");
  g_object_unref (module);

  auto resv = jsc_value_function_callv (func, G_N_ELEMENTS (args), args);
  g_object_unref (func);

  if (jsc_value_is_undefined (resv))


    variant = wakit_object_serializer_finish (instance);
  else

    if (gchar* str; ! jsc_value_object_is_instance_of (resv, "GError"))
      {

        g_set_error (error, WAKIT_MARSHALLING_ERROR,
                            WAKIT_MARSHALLING_ERROR_FAILED,
          "failed: %s", str = jsc_value_to_string (resv));
        g_free (str);
      }
    else if (JSCValue* val; true)
      {

        auto code = jsc_value_to_int32 (val = jsc_value_object_get_property (resv, "code"));
        g_object_unref (val);

        auto domain = g_quark_from_string (str = jsc_value_to_string (val = jsc_value_object_get_property (resv, "domain")));
        g_object_unref (val);
        g_free (str);

        auto message = jsc_value_to_string (val = jsc_value_object_get_property (resv, "message"));
        g_object_unref (val);

        g_set_error_literal (error, domain, code, message);
      }

return (g_object_unref (resv), g_object_unref (serializer), variant);
}

static GVariant* _floatXXarray_pack (JSCContext* context, JSCTypedArrayType atype, JSCValue* value)
{

  gsize length = jsc_value_typed_array_get_length (value),
          size = length * sizeof (gdouble);

  auto data = g_new (gchar, size);
  auto sptr = jsc_value_typed_array_get_data (value, nullptr);

  switch (atype)
    {

    case JSC_TYPED_ARRAY_FLOAT32: for (gsize i = 0; i < length; ++i)
                                    ((gdouble*) data) [i] = ((gfloat*) sptr) [i];

      G_STATIC_ASSERT (sizeof (gfloat) == 4);
      break;

    case JSC_TYPED_ARRAY_FLOAT64: memcpy (data, sptr, size);

      G_STATIC_ASSERT (sizeof (gdouble) == 8);
      break;

    default:
      g_assert_not_reached ();
    }

  auto bytes = g_bytes_new_take (data, size);
  auto variant = g_variant_new_from_bytes (G_VARIANT_TYPE ("ad"), bytes, false);

return (g_bytes_unref (bytes), variant);
}

[[gnu::always_inline]] static inline const GVariantType* _iter_init_good (const GVariantType* vtype)
{
  return g_variant_type_first (vtype);
}

[[gnu::always_inline]] static inline const GVariantType* _iter_next_good (const GVariantType*, const GVariantType* iter)
{
  return g_variant_type_next (iter);
}

template<char T> GVariant* _tuple_pack (JSCContext* context, const GVariantType* vtype, JSCValue* value, GError** error)
{

  GPtrArray* values = nullptr;
  GError* tmperr = nullptr;

  if (values = _valuearray_take<_iter_init_good, _iter_next_good> (context, vtype, value, &tmperr);
      G_UNLIKELY (nullptr != tmperr))

    return (g_propagate_error (error, tmperr), nullptr);

  GVariant* vr;

  if constexpr (T == '(')
    vr = g_variant_new_tuple ((GVariant**) values->pdata, values->len);

  else if constexpr (T == '{')
    vr = g_variant_new_dict_entry (((GVariant**) values->pdata) [0], ((GVariant**) values->pdata) [1]);

return (g_ptr_array_unref (values), vr);
}

template<size_t align>
[[gnu::always_inline]]
static inline GVariant* _typearray_make (const GVariantType* type, JSCValue* value)
{

  auto size = jsc_value_typed_array_get_size (value);
  auto data = jsc_value_typed_array_get_data (value, NULL /* element count, not byte count */);

  auto orig = (gchar*) g_malloc (align + bits::align_upto<align> (size));
  auto back = (gchar*) bits::align_upto<align> ((guintptr) orig);

  memcpy (back, data, size);

return g_variant_new_from_data (type, back, size, false, (GDestroyNotify) g_free, orig);
}

static GVariant* _typearray_pack (JSCContext* context, const GVariantType* child_type, JSCValue* value)
{

  char cs [3] = { 'a', 0, 0 };

  switch (auto vt = g_variant_type_peek_string (child_type) [0]; (cs [1] = vt))
    {

    case 'b': if (auto type = jsc_value_typed_array_get_type (value); type == JSC_TYPED_ARRAY_INT8
                                                                   || type == JSC_TYPED_ARRAY_UINT8)

                return _typearray_make<alignof (guint8)> (G_VARIANT_TYPE (cs), value);
              else
                return (jsc_context_throw (context, "(U)Int8Array expected"), nullptr);

    case 'd': if (auto type = jsc_value_typed_array_get_type (value); type == JSC_TYPED_ARRAY_FLOAT32
                                                                   || type == JSC_TYPED_ARRAY_FLOAT64)

                return _floatXXarray_pack (context, type, value);
              else
                return (jsc_context_throw (context, "Float32Array or Float64Array expected"), nullptr);

    case 'h': G_GNUC_FALLTHROUGH;

    case 'i': if (auto type = jsc_value_typed_array_get_type (value); type == JSC_TYPED_ARRAY_INT32)

                return _typearray_make<alignof (gint32)> (G_VARIANT_TYPE (cs), value);
              else
                return (jsc_context_throw (context, "Int32Array expected"), nullptr);

    case 'n': if (auto type = jsc_value_typed_array_get_type (value); type == JSC_TYPED_ARRAY_INT16)

                return _typearray_make<alignof (gint16)> (G_VARIANT_TYPE (cs), value);
              else
                return (jsc_context_throw (context, "Int16Array expected"), nullptr);

    case 'q': if (auto type = jsc_value_typed_array_get_type (value); type == JSC_TYPED_ARRAY_UINT16)

                return _typearray_make<alignof (guint16)> (G_VARIANT_TYPE (cs), value);
              else
                return (jsc_context_throw (context, "Uint16Array expected"), nullptr);

    case 't': if (auto type = jsc_value_typed_array_get_type (value); type == JSC_TYPED_ARRAY_UINT64)

                return _typearray_make<alignof (guint64)> (G_VARIANT_TYPE (cs), value);
              else
                return (jsc_context_throw (context, "Uint64Array expected"), nullptr);

    case 'u': if (auto type = jsc_value_typed_array_get_type (value); type == JSC_TYPED_ARRAY_UINT32)

                return _typearray_make<alignof (guint32)> (G_VARIANT_TYPE (cs), value);
              else
                return (jsc_context_throw (context, "Uint32Array expected"), nullptr);

    case 'x': if (auto type = jsc_value_typed_array_get_type (value); type == JSC_TYPED_ARRAY_INT64)

                return _typearray_make<alignof (gint64)> (G_VARIANT_TYPE (cs), value);
              else
                return (jsc_context_throw (context, "Int64Array expected"), nullptr);

    case 'y': if (auto type = jsc_value_typed_array_get_type (value); type == JSC_TYPED_ARRAY_UINT8)

                return _typearray_make<alignof (guint8)> (G_VARIANT_TYPE (cs), value);
              else
                return (jsc_context_throw (context, "Uint8Array expected"), nullptr);

    default:
      g_error ("unknown variant type '%s', fix this!", g_variant_type_peek_string (G_VARIANT_TYPE (cs)));
    }
# undef g_variant_new_from_jsc_value
}

[[gnu::always_inline]] static inline const GVariantType* _iter_init_same (const GVariantType* vtype)
{
  return vtype;
}

[[gnu::always_inline]] static inline const GVariantType* _iter_next_same (const GVariantType* vtype, const GVariantType*)
{
  return vtype;
}

static GVariant* _valuearray_pack (JSCContext* context, const GVariantType* child_type, JSCValue* value, GError** error)
{

  GError* tmperr = nullptr;
  GPtrArray* values = nullptr;

  if (values = _valuearray_take<_iter_init_same, _iter_next_same> (context, child_type, value, &tmperr);
      G_UNLIKELY (nullptr != tmperr))

    return (g_propagate_error (error, tmperr), nullptr);

  auto vr = g_variant_new_array (child_type, (GVariant**) values->pdata, values->len);

return (g_ptr_array_unref (values), vr);
}

template<TypeIterInit _iter_init,
         TypeIterNext _iter_next>
static GPtrArray* _valuearray_take (JSCContext* context, const GVariantType* vtype, JSCValue* value, GError** error)
{

  auto prop_v = jsc_value_object_get_property (value, "length");
  auto length = jsc_value_to_int32 (prop_v);

  auto ar = g_ptr_array_sized_new ((gsize) length);
  auto ti = _iter_init (vtype);
  g_object_unref (prop_v);

  GError* tmperr = nullptr;
  g_ptr_array_set_free_func (ar, (GDestroyNotify) g_variant_unref);

  for (decltype (length) i = 0; i < length; ++i, ti = _iter_next (vtype, ti))
    {

      auto item = jsc_value_object_get_property_at_index (value, i);
      auto resv = wakit_marshalling_jsc_value_to_variant (context, ti, item, &tmperr);

      if (g_object_unref (item); G_LIKELY (nullptr == tmperr))

        g_ptr_array_add (ar, g_variant_ref_sink (resv));
      else
        return (g_ptr_array_unref (ar), g_propagate_error (error, tmperr), nullptr);
    }
return ar;
}