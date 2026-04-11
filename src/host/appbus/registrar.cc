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

#define _g_object_unref0(var) ((NULL == var) ? NULL : (var = (g_object_unref (var), nullptr)))

void wakit_app_bus_registrar_impl_clear (WakitAppBusRegistrarImpl* impl)
{

  if (auto value = impl->bus_address; NULL != value)
    impl->bus_address = (g_free (value), nullptr);

  if (auto value = impl->connection; NULL != value)
    impl->connection = (g_object_unref (value), nullptr);

  if (auto value = impl->owned_id; 0 != value)
    impl->owned_id = (g_bus_unown_name (value), 0);
}

gboolean wakit_app_bus_registrar_impl_clear_last (WakitAppBusRegistrarImpl* impl, WakitBusMaster* master)
{

  gboolean bootstrap;

  if (! (bootstrap = NULL == impl->connection))
    {

      wakit_bus_master_release (master, impl->bus_address, impl->connection);
      wakit_app_bus_registrar_impl_clear (impl);
    }
return bootstrap;
}

void wakit_app_bus_registrar_impl_init (WakitAppBusRegistrarImpl* impl)
{

  impl->connection = NULL;
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

void wakit_app_bus_registrar_impl_switch_to (WakitAppBusRegistrarImpl* impl, WakitBusMaster* master, const gchar* bus_address, GDBusConnection* connection, GAsyncReadyCallback callback, gpointer user_data)
{

  auto future = g_task_new (NULL, NULL, callback, user_data);
  auto tmperr = (GError*) NULL;

  auto bootstrap = wakit_app_bus_registrar_impl_clear_last (impl, master);

  g_task_set_source_tag (future, (gpointer) wakit_app_bus_registrar_impl_switch_to);
  g_task_set_static_name (future, "Wakit.AppBus.Registrar.Impl.switch_to");

  if (wakit_bus_master_acquire (master, bus_address, connection, &tmperr); G_UNLIKELY (NULL != tmperr))
    return g_task_return_error (future, tmperr);

  auto flag1 = (GBusNameOwnerFlags) G_BUS_NAME_OWNER_FLAGS_DO_NOT_QUEUE;
  auto flags = (GBusNameOwnerFlags) flag1;

  struct _OwnerData data = { .future = future, .result = bootstrap };
  struct _OwnerData* pdata = g_slice_dup (struct _OwnerData, &data);

  impl->bus_address = g_strdup (bus_address);
  impl->connection = g_object_ref (connection);

  auto name = g_application_get_application_id ((GApplication*) master);

  auto id = g_bus_own_name_on_connection (connection, name, flags, (GBusNameAcquiredCallback) _name_acquired,
                                                                   (GBusNameLostCallback) _name_lost,
                                                                   pdata,
                                                                   (GDestroyNotify) _owner_data_free);

  impl->owned_id = id;
}

gboolean wakit_app_bus_registrar_impl_switch_to_finish (WakitAppBusRegistrarImpl* impl, GAsyncResult* result, GError** error)
{

  return g_task_propagate_boolean ((GTask*) result, error);
}