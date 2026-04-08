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
#include <host/application.h>

struct _WakApplicationPrivate
{

  gboolean ready;
};

struct _WakApplicationClassPrivate
{

  const gchar* extension_dir;
  gboolean launch_bus;
};

G_DEFINE_TYPE_WITH_CODE (WakApplication, wak_application, GTK_TYPE_APPLICATION,
  G_ADD_PRIVATE (WakApplication)
  g_type_add_class_private (g_define_type_id, sizeof (WakApplicationClassPrivate))
)

static void wak_application_class_dispose (GObject* pself)
{
  G_OBJECT_CLASS (wak_application_parent_class)->dispose (pself);
}

static void wak_application_class_finalize (GObject* pself)
{
  G_OBJECT_CLASS (wak_application_parent_class)->dispose (pself);
}

static void wak_application_class_init (WakApplicationClass* klass)
{

  G_OBJECT_CLASS (klass)->dispose = wak_application_class_dispose;
  G_OBJECT_CLASS (klass)->finalize = wak_application_class_finalize;
}

void wak_application_class_launch_app_bus (WakApplicationClass* klass, gboolean launch)
{

  g_return_if_fail (WAK_IS_APPLICATION_CLASS (klass));

  auto type = G_TYPE_FROM_CLASS (klass);
  auto priv = G_TYPE_CLASS_GET_PRIVATE (klass, type, WakApplicationClassPrivate);

  priv->launch_bus = launch;
}

void wak_application_class_set_extension_dir (WakApplicationClass* klass, const gchar* dir)
{

  g_return_if_fail (WAK_IS_APPLICATION_CLASS (klass));
  g_return_if_fail (NULL != dir);

  auto type = G_TYPE_FROM_CLASS (klass);
  auto priv = G_TYPE_CLASS_GET_PRIVATE (klass, type, WakApplicationClassPrivate);

  g_return_if_fail (NULL == priv->extension_dir);

  priv->extension_dir = g_intern_string (dir);
}

static void wak_application_init (WakApplication* self)
{

  self->priv = (WakApplicationPrivate*) wak_application_get_instance_private (self);
}