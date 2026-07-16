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
#include <glib.h>
#ifdef G_OS_UNIX
#include <gio/gunixinputstream.h>
#include <gio/gunixoutputstream.h>
#include <unistd.h>
#endif // G_OS_UNIX
#include <wakit/common/boxing.h>
#include <wakit/common/commandline.h>

gchar** wakit_command_line_ensure_argv (int* argc, char*** argv)
{
# if !defined(G_OS_WIN32)

return NULL;
# else // defined(G_OS_WIN32)
  gchar** new_argv = g_win32_get_command_line ();
  gint new_argc = g_strv_length (new_argv);

return (*argc = new_argc, *argv = new_argv, new_argv);
# endif // defined(G_OS_WIN32)
}

boxing::object<GInputStream> _stdin_stream;

GInputStream* wakit_command_line_get_stdin ()
{

  static GInputStream* __static = NULL;

  if (g_once_init_enter (&__static))
    {
    # ifdef G_OS_UNIX
      _stdin_stream = g_unix_input_stream_new (STDIN_FILENO, FALSE);
    # endif // G_OS_UNIX
      g_once_init_leave (&__static, *_stdin_stream);
    }
return __static;
}

boxing::object<GOutputStream> _stdout_stream;

GOutputStream* wakit_command_line_get_stdout ()
{

  static GOutputStream* __static = NULL;

  if (g_once_init_enter (&__static))
    {
    # ifdef G_OS_UNIX
      _stdout_stream = g_unix_output_stream_new (STDOUT_FILENO, FALSE);
    # endif // G_OS_UNIX
      g_once_init_leave (&__static, *_stdout_stream);
    }
return __static;
}

# if defined(G_OS_WIN32)

static GSourceFuncs never_source_callbacks =
{

  .prepare = [](GSource*, int*) -> gboolean
    { return false; },

  .check = [](GSource*) -> gboolean
    { return false; },

  .dispatch = [](GSource*, GSourceFunc, gpointer) -> gboolean
    { return G_SOURCE_REMOVE; },

  .finalize = nullptr,
  .closure_callback = nullptr,
  .closure_marshal = nullptr,
};

# else // !defined(G_OS_WIN32)
# include <glib-unix.h>

# endif // !defined(G_OS_WIN32)

GSource* wakit_command_line_interrupt_source_new ()
{

  GSource* source;
# if defined(G_OS_WIN32)
  source = g_source_new (&never_source_callbacks, sizeof (GSource));
# else // !defined(G_OS_WIN32)
  source = g_unix_signal_source_new (SIGINT);
# endif // defined(G_OS_WIN32)
return source;
}