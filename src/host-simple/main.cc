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
#include <common/wakit-common.h>
#include <host-simple/wakit-host-simple.h>

static inline void pmain (int argc, char* argv[], GError** error);

int main (int argc, char* argv[])
{

  GError* error = NULL;

  if (pmain (argc, argv, &error); G_LIKELY (NULL == error))
    return 0;

  if (G_OPTION_ERROR == error->domain)

    g_printerr ("%s\n", error->message);
  else
    g_printerr ("%s: %u: %s\n", g_quark_to_string (error->domain), error->code, error->message);

return (g_error_free (error), 1);
}

static inline void pmain (int argc, char* argv[], GError** error)
{

  GError* tmperr = NULL;
  auto args = wakit_command_line_ensure_argv (&argc, &argv);
  auto config = wakit_simple_configuration_capture (&argc, &argv, &tmperr);

  if (G_UNLIKELY (NULL != tmperr))
    return (g_propagate_error (error, tmperr), g_strfreev (args));

  auto application = wakit_simple_application_new (config);

  g_object_unref (config);
  g_application_run ((GApplication*) application, argc, argv);

return (g_object_unref (application), g_strfreev (args));
}