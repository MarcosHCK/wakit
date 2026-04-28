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
#include <common/asynclock.h>

struct _LockSource: public GSource
{
  GMutex* mutex;
};

static int check (GSource* source);
static gboolean dispatch (GSource* source, GSourceFunc callback, gpointer user_data);
static int prepare (GSource* source, gint* timeout);

static GSourceFuncs _LockSource_funcs =
{

  .prepare = prepare,
  .check = check,
  .dispatch = dispatch,
  .finalize = NULL,
  .closure_callback = NULL,
  .closure_marshal = NULL,
};

static int check (GSource* source)
{

  auto mutex = ((_LockSource*) source)->mutex;
return (int) g_mutex_trylock (mutex);
}

static gboolean dispatch (GSource* source, GSourceFunc callback, gpointer user_data)
{

  ((GAsyncReadyCallback) callback) (NULL, NULL, user_data);
return G_SOURCE_REMOVE;
}

static int prepare (GSource* source, gint* timeout)
{

return (*timeout = 0, (int) FALSE);
}

void wakit_async_lock (GMutex* mutex, int io_priority, GAsyncReadyCallback callback, gpointer user_data)
{

  g_return_if_fail (NULL != mutex);

  if (g_mutex_trylock (mutex))
    return callback (NULL, NULL, user_data);

  auto context = g_main_context_ref_thread_default ();
  auto source = (_LockSource*) g_source_new (&_LockSource_funcs, sizeof (_LockSource));

  source->mutex = mutex;
  g_source_set_callback (source, G_SOURCE_FUNC (callback), user_data, NULL);
  g_source_set_priority (source, io_priority);
  g_source_set_static_name (source, "[Wakit.async_lock]");
  g_source_attach (source, context);

  g_main_context_unref (context);
  g_source_unref (source);
}

void wakit_async_lock_finish (GAsyncResult* result G_GNUC_UNUSED)
{
}