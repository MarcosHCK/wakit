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
#include <webkit/webkit-web-process-extension.h>

#define WAKIT_TYPE_WEB_PAGE_PROXY (wakit_web_page_proxy_get_type ())
#define WAKIT_WEB_PAGE_PROXY(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), WAKIT_TYPE_WEB_PAGE_PROXY, WakitWebPageProxy))
#define WAKIT_IS_WEB_PAGE_PROXY(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), WAKIT_TYPE_WEB_PAGE_PROXY))
typedef struct _WakitWebPageProxy WakitWebPageProxy;

G_BEGIN_DECLS

  GType wakit_web_page_proxy_get_type (void) G_GNUC_CONST;

  WakitWebPageProxy* wakit_web_page_proxy_get_default (WebKitWebPage* web_page);
  WebKitWebPage* wakit_web_page_proxy_get_web_page (WakitWebPageProxy* proxy);
  gboolean wakit_web_page_proxy_user_message_received (WakitWebPageProxy* proxy, WebKitUserMessage* message);

  G_DEFINE_AUTOPTR_CLEANUP_FUNC (WakitWebPageProxy, g_object_unref)

G_END_DECLS