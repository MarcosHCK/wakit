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
#include <wakit/scripts/application.h>

using _parent = boxing::destructible_box<GOptionContext, g_option_context_free>;

common::application::application (const gchar* parameter_string) noexcept:
  _parent (g_option_context_new (parameter_string))
{

  auto context = **this;
  g_option_context_set_help_enabled (context, TRUE);
  g_option_context_set_ignore_unknown_options (context, FALSE);
  g_option_context_set_strict_posix (context, FALSE);
  g_option_context_set_translation_domain (context, "en_US");
}

int common::application::run (int argc, char** argv) noexcept
{

  auto context = **this;
  auto tmperr = G_ERROR_INIT;

# if !defined(G_OS_WIN32)

  if (g_option_context_parse (context, &argc, &argv, &tmperr); G_UNLIKELY (nullptr != tmperr))
    {
      g_printerr ("%s\n", tmperr->message);
      return (g_error_free (tmperr), 1);
    }
# else // defined(G_OS_WIN32)
  gchar** args = g_win32_get_command_line ();
  boxing::destructible_box<gchar*, g_strfreev> _args = args;

  if ((g_option_context_parse_strv (context, &args, &tmperr), (void) _args); G_UNLIKELY (nullptr == tmperr))

    { argc = g_strv_length (args);
      argv = args; }
  else
    { g_printerr ("%s\n", tmperr->message);
      return (g_error_free (tmperr), 1); }
# endif // defined(G_OS_WIN32)
  int result = 0;

  if (result = open (argc, argv, &tmperr); G_UNLIKELY (nullptr != tmperr))
    {

      if (G_OPTION_ERROR == tmperr->domain)

        g_printerr ("%s\n", tmperr->message);
      else
        g_critical ("%s: %u: %s\n", g_quark_to_string (tmperr->domain), tmperr->code, tmperr->message);

      g_error_free ((result = 1, tmperr));
    }
return result;
}