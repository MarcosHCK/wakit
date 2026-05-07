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
#include <sys/prctl.h>
#include <signal.h>

static void child_setup (gpointer user_data)
{

  prctl (PR_SET_PDEATHSIG, SIGINT);

  if (1 == getppid ())

    /* mitigate race condition (parent crashed before the prctl call above) */
    _exit (1);
}

void wakit_process_impl_setup_launcher (GSubprocessLauncher* launcher)
{

  g_subprocess_launcher_set_child_setup (launcher, child_setup, NULL, NULL);
}

void wakit_process_impl_terminate_gracefully (GSubprocess* subprocess)
{

  g_subprocess_send_signal (subprocess, SIGINT);
}