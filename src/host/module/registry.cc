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
#include <host/module/registry.h>

typedef struct _WakitHostModuleWatcher WakitHostModuleWatcher;

extern "C" {

void wakit_host_module_watcher_quit_async (WakitHostModuleWatcher* self,
                                           guint timeout,
                                           GAsyncReadyCallback _callback_,
                                           gpointer _user_data_);

gboolean wakit_host_module_watcher_quit_finish (WakitHostModuleWatcher* self,
                                                GAsyncResult* _res_,
                                                GError** error);
}

#define NONE ((void*) quit_complete)

static void quit_complete (WakitHostModuleWatcher* watcher, GAsyncResult* result, GAsyncQueue* async_queue) noexcept
{

  GError* tmperr = NULL;

  if (wakit_host_module_watcher_quit_finish (watcher, result, &tmperr); G_LIKELY (NULL == tmperr))

    g_async_queue_push (async_queue, NONE);
  else
    g_async_queue_push (async_queue, tmperr);
}

static void quit_worker (GTask* task, GObject* source_object, GAsyncQueue* async_queue, GCancellable*) noexcept
{

  GError *error = NULL,
         *tmperr = NULL;
  guint tasks = GPOINTER_TO_UINT (g_async_queue_pop (async_queue));

  for (; 0 < tasks; --tasks)
    {

      if (G_LIKELY (NONE == (tmperr = (GError*) g_async_queue_pop (async_queue))))
        continue;

      if (G_LIKELY (NULL == error)) { error = tmperr;
        continue; }

      g_critical ("Wakit.Host.Module.Watcher.quit_async()!: %s: %u: %s",
        g_quark_to_string (tmperr->domain), tmperr->code, tmperr->message);

      g_error_free (tmperr);
    }

return G_UNLIKELY (NULL != error) ? g_task_return_error (task, error) : g_task_return_boolean (task, TRUE);
}

void wakit_host_module_registry_quit_impl (GPtrArray* ptr_array, guint timeout, GAsyncReadyCallback callback, gpointer user_data)
{

  if (0 == ptr_array->len)
    return ;

  auto async_queue = g_async_queue_new ();
  auto watchers = (WakitHostModuleWatcher**) ptr_array->pdata;

  g_async_queue_push (async_queue, GUINT_TO_POINTER (ptr_array->len));

  for (decltype (ptr_array->len) i = 0; i < ptr_array->len; ++i)
    wakit_host_module_watcher_quit_async (watchers [i], timeout, (GAsyncReadyCallback) quit_complete, async_queue);

  auto task = g_task_new (NULL, NULL, callback, user_data);

  g_task_set_task_data (task, async_queue, (GDestroyNotify) g_async_queue_unref);
  g_task_set_static_name (task, "Wakit.Host.Module.Registry.quit_impl");
  g_task_set_source_tag (task, (gpointer) wakit_host_module_registry_quit_impl);

  g_task_run_in_thread (task, (GTaskThreadFunc) quit_worker);
  g_object_unref (task);
}

gboolean wakit_host_module_registry_quit_impl_finish (GAsyncResult* result, GError** error)
{

return g_task_propagate_boolean ((GTask*) result, error);
}