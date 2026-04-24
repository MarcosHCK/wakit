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
#include <host/interfaces/wakit-host-interfaces.h>

typedef struct _WakitBundleRegistrar WakitBundleRegistrar;

void wakit_bundle_registrar_free (WakitBundleRegistrar* registrar);
void wakit_bundle_registrar_handle_uri_scheme_request (WakitBundleRegistrar* registrar, WakitIUriRequest* request);
static void wakit_bundle_register_uri_scheme_with_registrar_callback (WakitIUriRequest* request, WakitBundleRegistrar* registrar);

static __inline void wakit_bundle_register_uri_scheme_with_registrar (const gchar* scheme, WakitIBrowser* browser, WakitBundleRegistrar* registrar)
{

  wakit_ibrowser_register_uri_scheme (browser, scheme, (WakitIBrowserUriRequestResolver) wakit_bundle_register_uri_scheme_with_registrar_callback,
                                      registrar,
                                      (GDestroyNotify) wakit_bundle_registrar_free);
}

static void wakit_bundle_register_uri_scheme_with_registrar_callback (WakitIUriRequest* request, WakitBundleRegistrar* registrar)
{

  wakit_bundle_registrar_handle_uri_scheme_request (registrar, request);
}