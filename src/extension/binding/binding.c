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
#include <glib-object.h>

#define WAKIT_BINDING_IBINDING_TYPE_NAME_QUARK (wakit_binding_ibinding_type_name_quark ())
static G_DEFINE_QUARK (wakit-binding-ibinding-type-name, wakit_binding_ibinding_type_name)

#define WAKIT_BINDING_IBINDING_TYPE_PATH_QUARK (wakit_binding_ibinding_type_path_quark ())
static G_DEFINE_QUARK (wakit-binding-ibinding-type-path, wakit_binding_ibinding_type_path)

typedef struct _WakitBindingIBinding WakitBindingIBinding;
static WakitBindingIBinding* wakit_binding_ibinding_class_default_ctor_build_cb (GPtrArray* args, gpointer user_data);

static __inline GCallback wakit_binding_ibinding_class_default_ctor_build (GType g_type, gpointer* user_data, GDestroyNotify* notify)
{

  if (notify) *notify = NULL;
  if (user_data) *user_data = GTYPE_TO_POINTER (g_type);

return G_CALLBACK (wakit_binding_ibinding_class_default_ctor_build_cb);
}

static WakitBindingIBinding* wakit_binding_ibinding_class_default_ctor_build_cb (GPtrArray* args, gpointer user_data)
{

  GType g_type = GPOINTER_TO_TYPE (user_data);
  GObject* object = g_object_take_ref (g_object_new (g_type, NULL));

return (WakitBindingIBinding*) object;
}