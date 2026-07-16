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
#include <wakit/common/asynchelp/asyncdelay.h>

static gboolean _source_callback (GTask* task)
{
  g_task_return_boolean (task, TRUE);
return G_SOURCE_REMOVE;
}

static gboolean _nothing_callback (GCancellable* cancellable, gpointer user_Data)
{

return G_SOURCE_REMOVE;
} 

void wakit_async_delay (guint timeout, int priority, GCancellable* cancellable, GAsyncReadyCallback callback, gpointer user_data)
{

  auto task = g_task_new (NULL, cancellable, callback, user_data);
  auto source = g_timeout_source_new (timeout);

  (g_task_set_source_tag) (task, (gpointer) wakit_async_delay);

  g_task_set_priority (task, priority);
  g_task_set_static_name (task, "[Wakit.async_delay]");

  auto context = g_main_context_get_thread_default ();
  auto cancellable_source = g_cancellable_source_new (cancellable);

  g_source_set_callback (cancellable_source, (GSourceFunc) _nothing_callback, NULL, NULL);

  g_source_add_child_source (source, cancellable_source);
  g_source_unref (cancellable_source);

  g_source_set_callback (source, (GSourceFunc) _source_callback, task, g_object_unref);
  g_source_set_priority (source, priority);
  g_source_set_static_name (source, "[Wakit.async_delay]");
  g_source_attach (source, context);
  g_source_unref (source);
}

gboolean wakit_async_delay_finish (GAsyncResult* result, GError** error)
{

return g_task_propagate_boolean ((GTask*) result, error);
}