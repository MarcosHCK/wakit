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
#include <glib/gi18n.h>
#include <host/wakit-host.h>
#include <locale.h>

typedef WakitHostConfigurationConfig Config;

static void on_configure_capture (WakitHostRunner* runner, Config* config) noexcept;

int main (int argc, char* argv[])
{

  bindtextdomain (GETTEXT_PACKAGE, DATA_DIR "/locale");
  bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
  textdomain (GETTEXT_PACKAGE);

  auto host = wakit_host_runner_new ();
  g_signal_connect (host, "configure-capture", G_CALLBACK (on_configure_capture), NULL);

  auto result = wakit_host_runner_run (host, argc, argv);
  g_object_unref (host);

return result;
}

static void on_configure_capture (WakitHostRunner* runner, Config* config) noexcept
{

  constexpr const char* fallback = "en_US";

  auto lang = wakit_configuration_config_get_preferred_language ((WakitConfigurationConfig*) config);
  auto left = (gchar*) nullptr;

  if (auto before = setlocale (LC_ALL, g_intern_string (lang)); G_UNLIKELY (NULL == before))
    {

      g_warning (_ ("invalid language '%s', falling back to '%s'"), lang, fallback);
      setlocale (LC_ALL, lang = g_intern_static_string (fallback));
    }

  setenv ("LC_ALL", left = g_strdup_printf ("%s.UTF-8", lang), TRUE);
  g_free (left);
}