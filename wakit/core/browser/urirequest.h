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
#include <libsoup/soup-message-headers.h>
#include <wakit/core/interfaces/wakit-core-interfaces.h>

G_BEGIN_DECLS

  static __inline void wakit_browser_uri_request_headers_foreach_impl (SoupMessageHeaders* headers, WakitIUriRequestHeadersForeachHeader foreach, gpointer user_data)
    {
      soup_message_headers_foreach (headers, foreach, user_data);
    }

G_END_DECLS