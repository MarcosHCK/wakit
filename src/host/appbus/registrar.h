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
#include <gio/gio.h>

typedef struct _WakitAppBusRegistrarImpl WakitAppBusRegistrarImpl;

G_BEGIN_DECLS

  struct _WakitAppBusRegistrarImpl
    {

      GDBusConnection* current;
      guint owned_id;
    };

  G_GNUC_INTERNAL WakitAppBusRegistrarImpl* wakit_app_bus_registrar_impl_dup (const WakitAppBusRegistrarImpl* self);
  G_GNUC_INTERNAL void wakit_app_bus_registrar_impl_free (WakitAppBusRegistrarImpl* self);

  G_GNUC_INTERNAL void wakit_app_bus_registrar_impl_clear (WakitAppBusRegistrarImpl* impl);
  G_GNUC_INTERNAL gboolean wakit_app_bus_registrar_impl_clear_last (WakitAppBusRegistrarImpl* impl, GApplication* app);
  G_GNUC_INTERNAL void wakit_app_bus_registrar_impl_init (WakitAppBusRegistrarImpl* impl);
  G_GNUC_INTERNAL void wakit_app_bus_registrar_impl_switch_to (WakitAppBusRegistrarImpl* impl, GApplication* app, GDBusConnection* connection, GAsyncReadyCallback callback, gpointer user_data);
  G_GNUC_INTERNAL gboolean wakit_app_bus_registrar_impl_switch_to_finish (WakitAppBusRegistrarImpl* impl, GAsyncResult* result, GError** error);

G_END_DECLS