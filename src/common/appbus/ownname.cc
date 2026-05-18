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
#include <common/appbus/ownname.h>

struct _OwnData
{

  GTask* future;
  guint handle;
  guint refcount;
};

#define _g_bus_unown_name0(var) ((0 == var) ? 0 : (var = (g_bus_unown_name (var), 0)))
#define _g_object_unref0(var) ((NULL == var) ? NULL : (var = (g_object_unref (var), nullptr)))

static void _own_data_unref (struct _OwnData* data)
{

  if (g_atomic_int_dec_and_test (&data->refcount))
    {

      _g_object_unref0 (data->future);
      _g_bus_unown_name0 (data->handle);

      g_slice_free (struct _OwnData, data);
    }
}

static void on_name_acquired (GDBusConnection* connection, const gchar* name, struct _OwnData* data)
{

  if (auto task = data->future; NULL != task)
    {

      g_task_return_pointer (task, GUINT_TO_POINTER (g_steal_handle_id (&data->handle)), NULL);
      _g_object_unref0 (data->future);
    }
}

static void on_name_lost (GDBusConnection* connection, const gchar* name, struct _OwnData* data)
{

  if (auto task = data->future; NULL != task)
    {

      g_task_return_new_error_literal (task, G_IO_ERROR, G_IO_ERROR_CLOSED, "connection is closed");
      _g_object_unref0 (data->future);
    }
}

void wakit_app_bus_own_name_async (GDBusConnection* connection, const gchar* name, GBusNameOwnerFlags flags, GCancellable* cancellable, GAsyncReadyCallback callback, gpointer user_data)
{

  auto task = g_task_new (connection, cancellable, callback, user_data);

  auto data = _OwnData { .future = g_object_ref (task), .handle = 0, .refcount = 2 };
  auto dptr = g_slice_dup (decltype (data), &data);

  g_task_set_task_data (task, dptr, (GDestroyNotify) _own_data_unref);

  auto hand = g_bus_own_name_on_connection (connection, name, flags, (GBusNameAcquiredCallback) on_name_acquired, (GBusNameLostCallback) on_name_lost, dptr, (GDestroyNotify) _own_data_unref);
  dptr->handle = hand;

  g_object_unref (task);
}

guint wakit_app_bus_own_name_finish (GAsyncResult* result, GError** error)
{
  return GPOINTER_TO_UINT (g_task_propagate_pointer ((GTask*) result, error));
}