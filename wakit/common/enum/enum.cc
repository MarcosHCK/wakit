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
#include <wakit/common/enum/enum.h>

extern "C" GQuark wakit_enum_error_quark (void) G_GNUC_CONST;

template<int error_code> static inline bool collect_base (GEnumValue* value, GError** dst_error, const gchar* format, va_list l)
                                            G_GNUC_PRINTF(3, 0);

template<int error_code> static inline bool collect_base (GEnumValue* value, GError** dst_error, const gchar* format, va_list l)
{

  auto null = NULL == value; if (G_UNLIKELY (null))
    {

      auto quark = wakit_enum_error_quark (); \
      auto error = g_error_new_valist (quark, error_code, format, l);

      g_propagate_error (dst_error, error);
    }
return null;
}

#define implementation(suffix,default) \
 ; \
template<int error_code> static inline auto collect_##suffix (GEnumValue* value, GError** error, const gchar* format, ...) \
                                            G_GNUC_PRINTF (3, 4); \
template<int error_code> static inline auto collect_##suffix (GEnumValue* value, GError** error, const gchar* format, ...) \
{ \
 ; \
  va_list l; \
  va_start (l, format); \
 ; \
  auto navail = collect_base<error_code> (value, error, format, l); \
  auto result = G_UNLIKELY (navail) ? ((default)) : value-> suffix; \
return (va_end (l), result); \
}

  implementation (value,-1)
  implementation (value_name,NULL)
#undef implementation

#define implementation(suffix,error_code) \
 ; \
gint wakit_enum_from_##suffix (const gchar* suffix, GType g_type, GError** error) \
{ \
  g_return_val_if_fail (suffix != NULL, -1); \
  g_return_val_if_fail (g_type_is_a (g_type, G_TYPE_ENUM), -1); \
  g_return_val_if_fail (error == NULL || *error == NULL, -1); \
 ; \
  auto klass = (GEnumClass*) g_type_class_ref (g_type); \
  auto value = (GEnumValue*) g_enum_get_value_by_##suffix (klass, suffix); \
 ; \
return (g_type_class_unref (klass), collect_value<error_code> (value, error, "unknown enum " G_STRINGIFY (suffix) " '%s'", suffix)); \
}

  implementation (name, 1)
  implementation (nick, 2)

#undef implementation

const gchar* wakit_enum_as_string (gint num_value, GType g_type, GError** error)
{

  g_return_val_if_fail (g_type_is_a (g_type, G_TYPE_ENUM), NULL);

  auto klass = (GEnumClass*) g_type_class_ref (g_type);
  auto value = (GEnumValue*) g_enum_get_value (klass, num_value);

return (g_type_class_unref (klass), collect_value_name<3> (value, error, "unknown enum value %i", num_value));
}

const gchar* wakit_enum_to_string (gint value, GType g_type)
{

  GError* tmperr = NULL;

  if (auto result = wakit_enum_as_string (value, g_type, &tmperr);
      G_UNLIKELY (NULL == tmperr))

    return result;
  else
    {

      const auto code = tmperr->code;
      const auto domain = g_quark_to_string (tmperr->domain);
      const auto message = tmperr->message;
      auto name = g_type_name (g_type);

      g_debug ("Wakit.Utility.Enum.as_string<%s>()!: %s: %u: %s", name, domain, code, message);
    }
return "unknown";
}