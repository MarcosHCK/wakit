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

typedef struct _WakitHostModuleRegistry WakitHostModuleRegistry;
typedef struct _WakitHostModuleWatcher WakitHostModuleWatcher;

G_BEGIN_DECLS

  G_GNUC_INTERNAL void wakit_host_module_registry_init_impl (WakitHostModuleRegistry* registry,
                                                             GPtrArray* watchers,
                                                             GPtrArray* modules,
                                                             int io_priority,
                                                             GCancellable* cancellable,
                                                             GAsyncReadyCallback callback, gpointer user_data);

  G_GNUC_INTERNAL gboolean wakit_host_module_registry_init_impl_finish (WakitHostModuleRegistry* registry,
                                                                        GAsyncResult* result, GError** error);

  G_GNUC_INTERNAL void wakit_host_module_registry_quit_impl (WakitHostModuleRegistry* registry,
                                                             GPtrArray* watchers,
                                                             guint timeout,
                                                             GAsyncReadyCallback callback, gpointer user_data);

  G_GNUC_INTERNAL gboolean wakit_host_module_registry_quit_impl_finish (WakitHostModuleRegistry* registry,
                                                                        GAsyncResult* result, GError** error);

G_END_DECLS