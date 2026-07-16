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
#include <glib-object.h>
#include <type_traits>
#include <webkit/webkit-web-process-extension.h>

#define g_value_init_set(value,suffix,g_type,...) (G_GNUC_EXTENSION ({ \
 ; \
    GType __g_type = ((g_type)); \
    GValue* __value = ((value)); \
    g_value_init (__value, __g_type); \
    g_value_set_##suffix (__value, __VA_ARGS__); \
  }))

template<unsigned N> static void g_value_unsets (GValue (&values) [N])
{

  for (std::remove_cvref_t<decltype (N)> i = 0; i < N; ++i)
    g_value_unset (&values [i]);
}

G_BEGIN_DECLS

  gpointer wakit_web_extension_get_default (void) G_GNUC_CONST;
  gpointer wakit_web_extension_new_default (WebKitWebProcessExtension* wk_extension, GVariant* parameters, GType g_type);

  WebKitScriptWorld* wakit_web_extension_get_script_world (gpointer extension);
  GType wakit_web_extension_get_type (void) G_GNUC_CONST;

G_END_DECLS