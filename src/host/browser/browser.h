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
#include <glib.h>

#define WAKIT_BROWSER_CSS_CODE ((const gchar*) browser_css)
#define WAKIT_BROWSER_CSS_CODE_LEN ((gsize) browser_css_len)

#define WAKIT_BROWSER_JS_CODE ((const gchar*) browser_js)
#define WAKIT_BROWSER_JS_CODE_LEN ((gsize) browser_js_len)

G_BEGIN_DECLS

  extern unsigned char browser_css [];
  extern unsigned int browser_css_len;

  extern unsigned char browser_js [];
  extern unsigned int browser_js_len;

G_END_DECLS