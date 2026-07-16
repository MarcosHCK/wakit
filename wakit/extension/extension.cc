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
#include <wakit/extension/extension.hh>
#include <webkit/webkit-web-process-extension.h>

#define WAKIT_TYPE_WEB_EXTENSION (wakit_web_extension_get_type ())

static gpointer extension;
static gpointer wakit_web_extension_new_default_once (WebKitWebProcessExtension* wk_extension, GVariant* parameters, GType g_type);

gpointer wakit_web_extension_get_default ()
{
  g_assert (nullptr != extension);
  return extension;
}

gpointer wakit_web_extension_new_default (WebKitWebProcessExtension* wk_extension, GVariant* parameters, GType g_type)
{

  if (g_once_init_enter (&extension))
    {

      auto object = wakit_web_extension_new_default_once (wk_extension, parameters, g_type);
      g_once_init_leave (&extension, object);
    }
return extension;
}

static void __attribute__((destructor)) wakit_web_extension_del_default (void)
{

  g_debug ("Web-Process-Extension unloaded");

  g_clear_object (&extension);
}

static gpointer wakit_web_extension_new_default_once (WebKitWebProcessExtension* wk_extension, GVariant* parameters, GType g_type)
{

  g_debug ("Web-Process-Extension loading");

  g_return_val_if_fail (WEBKIT_IS_WEB_PROCESS_EXTENSION (wk_extension), NULL);
  g_return_val_if_fail (nullptr != parameters, NULL);
  g_return_val_if_fail (g_type_is_a (g_type, WAKIT_TYPE_WEB_EXTENSION), NULL);

  GError* error = NULL;
  const gchar* names [] = { "parameters", "wk_extension" };
  GValue values [2] = { G_VALUE_INIT, G_VALUE_INIT };

  g_value_init_set (&values [0], variant, G_TYPE_VARIANT, parameters);
  g_value_init_set (&values [1], object, WEBKIT_TYPE_WEB_PROCESS_EXTENSION, wk_extension);

  gpointer object = g_object_new_with_properties (g_type, G_N_ELEMENTS (values), names, values);
  gboolean success = g_initable_init ((GInitable*) object, NULL, &error);

  if ((g_value_unsets (values), (void) success); G_UNLIKELY (nullptr != error))

    { g_error (_ ("can not initialize web extension: %s: %u: %s"), g_quark_to_string (error->domain), error->code, error->message);
      g_assert_not_reached (); }

return object;
}