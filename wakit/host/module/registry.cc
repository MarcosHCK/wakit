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
#include <wakit/common/slice.h>
#include <wakit/host/configuration/wakit-host-configuration.h>
#include <wakit/host/module/registry.h>

#define WAKIT_HOST_CONFIGURATION_TYPE_MODULE (wakit_host_configuration_module_get_type ())
#define WAKIT_HOST_MODULE_TYPE_REGISTRY (wakit_host_module_registry_get_type ())

extern "C" {

GType wakit_host_configuration_module_get_type (void) G_GNUC_CONST;
GType wakit_host_module_registry_get_type (void) G_GNUC_CONST;

void wakit_host_module_registry_init_one (WakitHostModuleRegistry* self,
                                          WakitHostConfigurationModule* module,
                                          int io_priority,
                                          GCancellable* cancellable,
                                          GAsyncReadyCallback callback, gpointer user_data);

WakitHostModuleWatcher* wakit_host_module_registry_init_one_finish (WakitHostModuleRegistry* self,
                                                                    GAsyncResult* _res_,
                                                                    GError** error);

void wakit_host_module_watcher_quit_async (WakitHostModuleWatcher* self,
                                           guint timeout,
                                           GAsyncReadyCallback _callback_,
                                           gpointer _user_data_);

gboolean wakit_host_module_watcher_quit_finish (WakitHostModuleWatcher* self,
                                                GAsyncResult* _res_,
                                                GError** error);
}

template<typename TData>
static void worker (GTask* task, GObject* source_object, TData* data, GCancellable*) noexcept;

static gpointer __none_tag_addr = NULL;
static gpointer __none = &__none_tag_addr;

struct _InitImplData
{

  GAsyncQueue* async_queue;
  guint tasks;
  GPtrArray* watchers;

  inline ~_InitImplData () noexcept
    {
      g_async_queue_unref (async_queue);
      g_ptr_array_unref (watchers);
    }

  inline _InitImplData (GPtrArray* _watchers, guint _tasks) noexcept:
      async_queue (g_async_queue_new ()),
      tasks (_tasks),
      watchers (g_ptr_array_ref (_watchers))
    { }
};

static void init_complete (WakitHostModuleRegistry* registry, GAsyncResult* result, _InitImplData* data) noexcept
{

  GError* tmperr = NULL;

  if (auto watcher = wakit_host_module_registry_init_one_finish (registry, result, &tmperr); G_UNLIKELY (NULL != tmperr))
    g_async_queue_push (data->async_queue, tmperr);

  else if (auto async_queue = data->async_queue; TRUE)
    {

      g_async_queue_lock (async_queue);
      g_ptr_array_add (data->watchers, watcher);
      g_async_queue_push_unlocked (async_queue, __none);
      g_async_queue_unlock (async_queue);
    }
}

void wakit_host_module_registry_init_impl (WakitHostModuleRegistry* registry,
                                           GPtrArray* watchers,
                                           GPtrArray* _modules,
                                           int io_priority,
                                           GCancellable* cancellable,
                                           GAsyncReadyCallback callback, gpointer user_data)
{

  g_return_if_fail (G_TYPE_CHECK_INSTANCE_TYPE (registry, WAKIT_HOST_MODULE_TYPE_REGISTRY));
  g_return_if_fail (NULL != watchers);
  g_return_if_fail (NULL == cancellable || G_IS_CANCELLABLE (cancellable));

  auto modules = (WakitHostConfigurationModule**) _modules->pdata;
  auto n_modules = _modules->len;

  for (decltype (n_modules) i = 0; i < n_modules; ++i)
    g_return_if_fail (G_TYPE_CHECK_INSTANCE_TYPE (modules[i], WAKIT_HOST_CONFIGURATION_TYPE_MODULE));

  auto data = g_slice_new_<_InitImplData> (watchers, n_modules);

  for (decltype (n_modules) i = 0; i < n_modules; ++i)
    wakit_host_module_registry_init_one (registry, modules [i], io_priority, cancellable, (GAsyncReadyCallback) init_complete, data);

  auto task = g_task_new (registry, NULL, callback, user_data);

  g_task_set_task_data (task, data, (GDestroyNotify) g_slice_free_<_InitImplData>);
  g_task_set_static_name (task, "Wakit.Host.Module.Registry.init_impl");
  g_task_set_source_tag (task, (gpointer) wakit_host_module_registry_init_impl);

  g_task_run_in_thread (task, (GTaskThreadFunc) worker<_InitImplData>);
  g_object_unref (task);
}

gboolean wakit_host_module_registry_init_impl_finish (WakitHostModuleRegistry* registry,
                                                      GAsyncResult* result, GError** error)
{

return g_task_propagate_boolean ((GTask*) result, error);
}

struct _QuitImplData
{

  GAsyncQueue* async_queue;
  guint tasks;

  inline ~_QuitImplData ()
    {
      g_async_queue_unref (async_queue);
    }

  inline _QuitImplData (guint _tasks) noexcept:
      async_queue (g_async_queue_new ()),
      tasks (_tasks)
    { }
};

static void quit_complete (WakitHostModuleWatcher* watcher, GAsyncResult* result, _QuitImplData* data) noexcept
{

  GError* tmperr = NULL;

  if (wakit_host_module_watcher_quit_finish (watcher, result, &tmperr); G_UNLIKELY (NULL != tmperr))

    g_async_queue_push (data->async_queue, tmperr);
  else
    g_async_queue_push (data->async_queue, __none);
}

void wakit_host_module_registry_quit_impl (WakitHostModuleRegistry* registry,
                                           GPtrArray* _watchers,
                                           guint timeout,
                                           GAsyncReadyCallback callback, gpointer user_data)
{

  auto n_watchers = _watchers->len;
  auto watchers = (WakitHostModuleWatcher**) _watchers->pdata;

  auto data = g_slice_new_<_QuitImplData> (n_watchers);

  for (decltype (n_watchers) i = 0; i < n_watchers; ++i)
    wakit_host_module_watcher_quit_async (watchers [i], timeout, (GAsyncReadyCallback) quit_complete, data);

  auto task = g_task_new (registry, NULL, callback, user_data);

  g_task_set_task_data (task, data, (GDestroyNotify) g_slice_free_<_QuitImplData>);
  g_task_set_static_name (task, "Wakit.Host.Module.Registry.quit_impl");
  g_task_set_source_tag (task, (gpointer) wakit_host_module_registry_quit_impl);

  g_task_run_in_thread (task, (GTaskThreadFunc) worker<_QuitImplData>);
  g_object_unref (task);
}

gboolean wakit_host_module_registry_quit_impl_finish (WakitHostModuleRegistry* registry,
                                                      GAsyncResult* result, GError** error)
{

return g_task_propagate_boolean ((GTask*) result, error);
}

template<typename TData>
static void worker (GTask* task, GObject* source_object, TData* data, GCancellable*) noexcept
{

  GError *error = NULL,
         *tmperr = NULL;

  auto async_queue = data->async_queue;

  for (auto tasks = data->tasks; 0 < tasks; --tasks)
    {

      if (G_LIKELY (__none == (tmperr = (GError*) g_async_queue_pop (async_queue))))
        continue;

      if (G_LIKELY (NULL == error)) { error = tmperr;
        continue; }

      g_critical ("Wakit.Host.Module.Watcher.worker()!: %s: %u: %s",
        g_quark_to_string (tmperr->domain), tmperr->code, tmperr->message);

      g_error_free (tmperr);
    }
return G_UNLIKELY (NULL != error) ? g_task_return_error (task, error) : g_task_return_boolean (task, TRUE);
}