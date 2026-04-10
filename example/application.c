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
#include <host/wakit-host.h>

static void on_activate (WakitApplication* app);

int main (int argc, char* argv [])
{

  GApplication* app;
  int ret;

  app = g_object_new (WAKIT_TYPE_APPLICATION, "application-id", "org.hck.wakit.example",
                                                       "flags", G_APPLICATION_DEFAULT_FLAGS,
                           NULL);

  g_signal_connect (app, "activate", G_CALLBACK (on_activate), NULL);

  ret = g_application_run (G_APPLICATION (app), argc, argv);

return (g_object_unref (app), ret);
}

static void on_activate (WakitApplication* app)
{
  g_application_hold (app);
}