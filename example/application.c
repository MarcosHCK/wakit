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
#include <host/gui/wakit-host-gui.h>
#include <host/wakit-host.h>

static void on_activate (WakitApplication* app);
static void on_open_uris (WakitApplication* app, GFile** files, gint n_files, const gchar* hint);

int main (int argc, char* argv [])
{

  GApplication* app;
  int ret;

  app = g_object_new (WAKIT_TYPE_APPLICATION, "application-id", "org.hck.wakit.example",
                                                       "flags", G_APPLICATION_HANDLES_OPEN,
                           NULL);

  g_signal_connect (app, "activate", G_CALLBACK (on_activate), NULL);
  g_signal_connect (app, "open-uris", G_CALLBACK (on_open_uris), NULL);

  ret = g_application_run (G_APPLICATION (app), argc, argv);

return (g_object_unref (app), ret);
}

static void on_activate (WakitApplication* app)
{

  GFile* uri = g_file_new_for_uri ("about:blank");
  GFile* uris [1] = { uri };

  g_application_open ((GApplication*) app, uris, 1, "");
  g_object_unref (uri);
}

static void on_open_uris (WakitApplication* app, GFile** files, gint n_files, const gchar* hint)
{

  GtkWindow* window = (GtkWindow*) wakit_gui_window_new ((GtkApplication*) app);
  wakit_gui_window_set_has_titlebar ((WakitGuiWindow*) window, TRUE);
  gtk_window_set_child (window, (GtkWidget*) wakit_ibrowser_make_viewer (wakit_application_get_browser (app)));
  gtk_window_present (window);
}