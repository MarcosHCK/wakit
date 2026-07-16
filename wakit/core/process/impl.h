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

G_BEGIN_DECLS

  void wakit_process_impl_setup_launcher (GSubprocessLauncher* launcher);
  void wakit_process_impl_terminate_gracefully (GSubprocess* subprocess);
  void wakit_process_impl_terminate_gracefully_and_wait (GSubprocess* subprocess, GCancellable* cancellable, GAsyncReadyCallback callback, gpointer user_data);
  void wakit_process_impl_terminate_gracefully_and_wait_finish (GAsyncResult* result, GError** error);

G_END_DECLS