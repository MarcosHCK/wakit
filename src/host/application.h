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
#pragma once
#include <glib-object.h>
#include <gtk/gtk.h>

#define WAK_TYPE_APPLICATION (wak_application_get_type ())
#define WAK_APPLICATION(obj) (G_TYPE_CHECK_INSTANCE_CAST((obj), WAK_TYPE_APPLICATION, WakApplication))
#define WAK_IS_APPLICATION(obj) (G_TYPE_CHECK_INSTANCE_TYPE((obj), WAK_TYPE_APPLICATION))
typedef struct _WakApplication WakApplication;
typedef struct _WakApplicationPrivate WakApplicationPrivate;

#define WAK_APPLICATION_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST((klass), WAK_TYPE_APPLICATION, WakApplicationClass))
#define WAK_IS_APPLICATION_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE((klass), WAK_TYPE_APPLICATION))
#define WAK_APPLICATION_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS((obj), WAK_TYPE_APPLICATION, WakApplicationClass))
typedef struct _WakApplicationClass WakApplicationClass;
typedef struct _WakApplicationClassPrivate WakApplicationClassPrivate;

G_BEGIN_DECLS

  struct _WakApplication
    {

      GtkApplication parent;
      WakApplicationPrivate* priv;
    };

  struct _WakApplicationClass
    {
      GtkApplicationClass parent;
      WakApplicationClassPrivate* priv;
    };

  GType wak_application_get_type (void) G_GNUC_CONST;

  void wak_application_class_launch_app_bus (WakApplicationClass* klass, gboolean launch);
  void wak_application_class_set_extension_dir (WakApplicationClass* klass, const gchar* dir);

G_END_DECLS