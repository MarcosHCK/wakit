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
#include <gmodule.h>
#include <wakit/extension/wakit-extension.h>

static void on_registration (JSCContext* context, WebKitWebPage* web_page, WebKitFrame* frame)
{
}

G_MODULE_EXPORT void webkit_web_process_extension_initialize_with_user_data (WebKitWebProcessExtension* wk_extension,
                                                                             const GVariant* parameters)
{

  auto object = wakit_web_extension_new_default (wk_extension, parameters, WAKIT_TYPE_WEB_EXTENSION);

  g_signal_connect (object, "registration", G_CALLBACK (on_registration), object);
}