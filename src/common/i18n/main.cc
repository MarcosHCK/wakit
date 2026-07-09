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
#include <common/i18n/main.h>
#include <clocale>

void wakit_i18n_app_setup (const char* lang)
{

  setlocale (LC_ALL, lang);
  bindtextdomain (GETTEXT_PACKAGE, DATA_DIR "/locale");
  bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
  textdomain (GETTEXT_PACKAGE);
}

void wakit_i18n_lib_setup (void)
{

  bindtextdomain (GETTEXT_PACKAGE, DATA_DIR "/locale");
  bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
}