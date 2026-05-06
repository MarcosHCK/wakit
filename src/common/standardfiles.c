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
#include <gio/gio.h>

#ifdef G_OS_UNIX
#include <gio/gunixinputstream.h>
#include <unistd.h>

static __inline GInputStream* wakit_standard_files_open_stdin_impl ()
{

return g_unix_input_stream_new (STDIN_FILENO, FALSE);
}

#endif // G_OS_UNIX