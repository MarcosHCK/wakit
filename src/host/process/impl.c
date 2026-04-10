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
#include <host/process/impl.h>

#ifdef G_OS_UNIX
# include "impl.unix.c"
#endif // G_OS_UNIX

#ifdef G_OS_WIN32
# include "impl.win32.c"
#endif // G_OS_WIN32

void wakit_process_impl_terminate_gracefully_and_wait (GSubprocess* subprocess, GCancellable* cancellable, GAsyncReadyCallback callback, gpointer user_data)
{

  g_subprocess_wait_check_async (subprocess, cancellable, callback, user_data);
  wakit_process_impl_terminate_gracefully (subprocess);
}

void wakit_process_impl_terminate_gracefully_and_wait_finish (GAsyncResult* result, GError** error)
{

  GError* tmperr = NULL;
  g_subprocess_wait_check_finish ((GSubprocess*) g_async_result_get_source_object (result), result, error);

  if (G_UNLIKELY (NULL == tmperr))

    return;
  else

    if (g_error_matches (tmperr, G_SPAWN_ERROR, G_SPAWN_ERROR_FAILED))

      g_error_free (tmperr);
    else
      g_propagate_error (error, tmperr);
}