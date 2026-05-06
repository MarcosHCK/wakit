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
#include <glib-unix.h>

static __inline void wakit_busmaster_application_sigint_source_add (GMainContext* context, GSourceFunc func, gpointer data, GDestroyNotify notify)
{

  GSource* source = g_unix_signal_source_new (SIGINT);

  g_source_set_callback (source, func, data, notify);
  g_source_set_priority (source, G_PRIORITY_HIGH);
  g_source_set_static_name (source, "[Wakit.Busmaster.Application.sigint_source_add]");

  g_source_attach (source, context);
  g_source_unref (source);
}