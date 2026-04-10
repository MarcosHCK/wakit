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
#include <host/appbus/registrar.h>

#define NULL_H 0
#define _g_object_unref0(var) ((NULL == var) ? NULL : (var = (g_object_unref (var), NULL)))

void wakit_app_bus_registrar_impl_clear (WakitAppBusRegistrarImpl* impl)
{

  if (NULL != impl->current)
    impl->current = (g_object_unref (impl->current), NULL);

  if (NULL_H != impl->owned_id)
    impl->owned_id = (g_bus_unown_name (impl->owned_id), NULL_H);
}

static gchar* build_path (const gchar* app_id)
{

  GString* gstr;
  gsize i, length = strlen (app_id);

  gstr = g_string_sized_new (2 + length);

  g_string_append_len (gstr, "/", 1);
  g_string_append_len (gstr, app_id, length);

  i = 1;

  for (gchar* ptr = gstr->str; i < gstr->len; ++i) if ('.' == ptr [i])
    ptr [i] = '/';

return g_string_free_and_steal (gstr);
}

gboolean wakit_app_bus_registrar_impl_clear_last (WakitAppBusRegistrarImpl* impl, GApplication* app)
{

  gboolean bootstrap;
  GApplicationClass* klass = G_APPLICATION_GET_CLASS (app);

  const gchar* name = g_application_get_application_id (app);
        gchar* path = build_path (name);

  if (! (bootstrap = NULL == impl->current))
    {

      klass->dbus_unregister (app, impl->current, path);
      wakit_app_bus_registrar_impl_clear (impl);
    }
return (g_free (path), bootstrap);
}

void wakit_app_bus_registrar_impl_init (WakitAppBusRegistrarImpl* impl)
{

  impl->current = NULL;
  impl->owned_id = 0;
}

struct _OwnerData
{

  GTask* future;
  gboolean result;
};

static void _name_acquired (GDBusConnection* connection, const gchar* name, struct _OwnerData* data)
{

  GTask* future; if (NULL != (future = data->future))
    {

      g_task_return_boolean (future, data->result);
      _g_object_unref0 (data->future);
    }
}

static void _name_lost (GDBusConnection* connection, const gchar* name, struct _OwnerData* data)
{

  GTask* future; if (NULL != (future = data->future))
    {

      g_task_return_new_error_literal (future, G_IO_ERROR, G_IO_ERROR_CANCELLED, "operation cancelled");
      _g_object_unref0 (data->future);
    }
}

static void _owner_data_free (struct _OwnerData* data)
{
  _name_lost (NULL, NULL, data);
}

void wakit_app_bus_registrar_impl_switch_to (WakitAppBusRegistrarImpl* impl, GApplication* app, GDBusConnection* connection, GAsyncReadyCallback callback, gpointer user_data)
{

  gboolean bootstrap;
  GApplicationClass* klass = G_APPLICATION_GET_CLASS (app);

  const gchar* name = g_application_get_application_id (app);
        gchar* path = build_path (name);

  if (! (bootstrap = NULL == impl->current))
    {

      klass->dbus_unregister (app, connection, path);
      wakit_app_bus_registrar_impl_clear (impl);
    }

  GTask* future = g_task_new (NULL, NULL, callback, user_data);
  GError* tmperr = NULL;

  g_task_set_source_tag (future, (gpointer) wakit_app_bus_registrar_impl_switch_to);
  g_task_set_static_name (future, "Wakit.AppBus.Registrar.Impl.switch_to");

  klass->dbus_register (app, connection, path, &tmperr);
  g_free (path);

  if (G_UNLIKELY (NULL != tmperr))
    return g_task_return_error (future, tmperr);

  GBusNameOwnerFlags flag1 = G_BUS_NAME_OWNER_FLAGS_DO_NOT_QUEUE;
  GBusNameOwnerFlags flags = flag1;

  struct _OwnerData data = { .future = future, .result = bootstrap };
  struct _OwnerData* pdata = g_slice_dup (struct _OwnerData, &data);

  guint id = g_bus_own_name_on_connection (connection, name, flags, (GBusNameAcquiredCallback) _name_acquired,
                                                                    (GBusNameLostCallback) _name_lost,
                                                                    pdata,
                                                                    (GDestroyNotify) _owner_data_free);

  impl->current = g_object_ref (connection);
  impl->owned_id = id;
}

gboolean wakit_app_bus_registrar_impl_switch_to_finish (WakitAppBusRegistrarImpl* impl, GAsyncResult* result, GError** error)
{

  return g_task_propagate_boolean ((GTask*) result, error);
}