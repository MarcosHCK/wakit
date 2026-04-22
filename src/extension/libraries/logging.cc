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
#include <common/mixin.h>
#include <extension/libraries/logging.h>
#include <span>
#include <type_traits>

G_DEFINE_FLAGS_TYPE (GLogLevel, g_log_level,

  G_DEFINE_ENUM_VALUE (G_LOG_LEVEL_ERROR, "error"),
  G_DEFINE_ENUM_VALUE (G_LOG_LEVEL_CRITICAL, "critical"),
  G_DEFINE_ENUM_VALUE (G_LOG_LEVEL_WARNING, "warning"),
  G_DEFINE_ENUM_VALUE (G_LOG_LEVEL_MESSAGE, "message"),
  G_DEFINE_ENUM_VALUE (G_LOG_LEVEL_INFO, "info"),
  G_DEFINE_ENUM_VALUE (G_LOG_LEVEL_DEBUG, "debug")
)

template<typename T>
[[gnu::always_inline]] static inline void _g_object_unref (T value) noexcept
{

  g_object_unref (value);
}

template<typename T, unsigned N>
[[gnu::always_inline]] static inline void _g_object_unref (T (&values) [N]) noexcept
{

  for (std::remove_cvref_t<decltype (N)> i = 0; i < N; ++i)
    g_object_unref (values [i]);
}

using value_box = boxing::object<JSCValue>;

static void log_callback (GPtrArray* array, GFlagsClass* flags_class);
static JSCValue* make_codeloc (JSCContext* context, JSCValue* ctr);
static JSCValue* make_log_func (JSCContext* context, JSCValue* logfunc, JSCValue* codeloc, JSCValue* ctr, GLogLevelFlags flags);
static JSCValue* make_log_level (JSCContext* context, GFlagsClass* flags_class);

extern unsigned char logging_js [];
extern unsigned int logging_js_len;

JSCValue* wakit_libraries_logging_register (JSCContext* context)
{

  auto flags_type = g_log_level_get_type ();
  auto flags_class = (GFlagsClass*) g_type_class_ref (flags_type);
  JSCValue* tmp;

  auto lib = jsc_value_new_object (context, nullptr, nullptr);
  auto log = jsc_value_new_function_variadic (context, "log", G_CALLBACK (log_callback), flags_class, g_type_class_unref, G_TYPE_NONE);

  auto ctr = jsc_context_evaluate_with_source_uri (context, (const gchar*) logging_js, logging_js_len,
    "wakit:///extension/libraries/logging.js", 1);

  JSCValue* codeloc;
  jsc_value_object_set_property (lib, "codeloc", (codeloc = make_codeloc (context, ctr)));
  jsc_value_object_set_property (lib, "log", log);
  jsc_value_object_set_property (lib, "log_level", tmp = make_log_level (context, flags_class));

  JSCValue* cleanup [] = { ctr, codeloc, log };
  g_object_unref (tmp);

  for (value_box func; const auto& value: std::span (flags_class->values, flags_class->n_values))

    jsc_value_object_set_property (lib, value.value_nick, *(func = make_log_func (context, log, codeloc, ctr,
      (GLogLevelFlags) value.value)));

return (_g_object_unref (cleanup), lib);
}

#define throw(...) jsc_context_throw_printf (jsc_context_get_current (), __VA_ARGS__)
#define throw_literal(message) jsc_context_throw (jsc_context_get_current (), ((message)))

static void log_callback (GPtrArray* array, GFlagsClass* flags_class)
{

  constexpr auto n_base_args = 2;

  if (array->len < n_base_args)
    return throw_literal ("at least 2 values expected");

  if ((array->len - n_base_args) & 1)
    return throw_literal ("field arguments must come name-value pairs");

  gchar* domain = nullptr;
  guint log_level = 0;
  guint n_fields = (array->len - n_base_args) / 2;
  JSCValue** values = (JSCValue**) array->pdata;

  domain = jsc_value_to_string (values [0]);

  if (log_level = jsc_value_to_double (values [1]); log_level != (log_level & flags_class->mask))
    {
      auto left = log_level & ~flags_class->mask;
      return throw ("unknown log level flag value %u", left);
    }

  _mixin_new (boxing::string, keys, 16, n_fields);
  _mixin_new (boxing::bytes, bytes, 16, n_fields);
  _mixin_new (GLogField, fields, 1 + 16, 1 + n_fields);

  if (TRUE)
    {

      fields [0].key = "GLIB_DOMAIN";
      fields [0].length = strlen (domain);
      fields [0].value = domain;
    }

  for (guint i = n_base_args, j = 0, k = 1; i < array->len; i += 2, ++j, ++k)
    {

      gsize size;

      fields [k].key = *(keys [j] = jsc_value_to_string (values [i + 0]));
      fields [k].value = g_bytes_get_data (*(bytes [j] = jsc_value_to_string_as_bytes (values [i + 1])), &size);
      fields [k].length = size;
    }

  g_log_structured_array ((GLogLevelFlags) log_level, fields, 1 + n_fields);

return g_free (domain);
}

static inline const gchar* log_level_to_priority (GLogLevelFlags log_level)
{

  if (log_level & G_LOG_LEVEL_ERROR)
    return "3";
  else if (log_level & G_LOG_LEVEL_CRITICAL)
    return "4";
  else if (log_level & G_LOG_LEVEL_WARNING)
    return "4";
  else if (log_level & G_LOG_LEVEL_MESSAGE)
    return "5";
  else if (log_level & G_LOG_LEVEL_INFO)
    return "6";
  else if (log_level & G_LOG_LEVEL_DEBUG)
    return "7";

return "5";
}

static JSCValue* make_codeloc (JSCContext* context, JSCValue* ctr)
{

  auto error = jsc_context_get_value (context, "Error");
  auto generator = jsc_value_object_get_property (ctr, "codeloc");

  JSCValue* args [] = { error };
  JSCValue* result = jsc_value_function_callv (generator, G_N_ELEMENTS (args), args);
  g_object_unref (generator);

return (_g_object_unref (args), result);
}

static JSCValue* make_log_func (JSCContext* context, JSCValue* log, JSCValue* codeloc, JSCValue* ctr, GLogLevelFlags flags)
{

  auto level = jsc_value_new_number (context, flags);
  auto generator = jsc_value_object_get_property (ctr, "log_func");

  JSCValue* args [] = { g_object_ref (codeloc), level, g_object_ref (log),
                        jsc_value_new_string (context, log_level_to_priority (flags)) };
  JSCValue* result = jsc_value_function_callv (generator, G_N_ELEMENTS (args), args);
  g_object_unref (generator);

return (_g_object_unref (args), result);
}

static JSCValue* make_log_level (JSCContext* context, GFlagsClass* flags_class)
{

  auto object = jsc_value_new_object (context, nullptr, nullptr);

  for (const auto& enum_value: std::span (flags_class->values, flags_class->n_values))
    {

      auto value = jsc_value_new_number (context, (gdouble) enum_value.value);

      switch (auto name = enum_value.value_name; name [sizeof ("G_LOG_") - 1]) while (TRUE)
        {

          g_object_unref (value);
            break;

          case 'F': jsc_value_object_set_property (object, name + (sizeof ("G_LOG_FLAG_") - 1), value);
            continue;

          case 'L': jsc_value_object_set_property (object, name + (sizeof ("G_LOG_LEVEL_") - 1), value);
            continue;

          default: g_assert_not_reached ();
    } }
return (g_type_class_unref (flags_class), object);
}