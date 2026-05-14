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
#include <common/commandline.h>

gchar** wakit_command_line_ensure_argv (int* argc, char*** argv)
{
#if !defined(G_OS_WIN32)

return NULL;
#else // defined(G_OS_WIN32)
  gchar** new_argv = g_win32_get_command_line ();
  gint new_argc = g_strv_length (new_argv);

return (*argc = new_argc, *argv = new_argv, new_argv);
#endif // defined(G_OS_WIN32)
}