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

G_BEGIN_DECLS

  GDestroyNotify wakit_ffi_destroy_notify_for_boxed (GType g_type) G_GNUC_CONST;
  gboolean wakit_ffi_destroy_notify_type_is_primitive (GType g_type) G_GNUC_CONST;
  GDestroyNotify wakit_ffi_destroy_notify_using_value_table (GType g_type, GTypeValueTable* table) G_GNUC_CONST;

  static __inline GDestroyNotify wakit_ffi_destroy_notify_for_type (GType g_type)
    {

      if (g_type_is_a (g_type, G_TYPE_BOXED))
        return wakit_ffi_destroy_notify_for_boxed (g_type);

      else if (g_type_is_a (g_type, G_TYPE_OBJECT))
        return (GDestroyNotify) g_object_unref;

      else if (g_type_is_a (g_type, G_TYPE_PARAM))
        return (GDestroyNotify) g_param_spec_unref;

      else if (g_type_is_a (g_type, G_TYPE_STRING))
        return (GDestroyNotify) g_free;

      else if (g_type_is_a (g_type, G_TYPE_VARIANT))
        return (GDestroyNotify) g_variant_unref;

      else if (wakit_ffi_destroy_notify_type_is_primitive (g_type))
        return (GDestroyNotify) NULL;

      else if (auto table = g_type_value_table_peek (g_type))
        return wakit_ffi_destroy_notify_using_value_table (g_type, table);

      else
        g_critical ("could not guess destroy function for type %s", g_type_name (g_type));
        return (GDestroyNotify) NULL;
    }

G_END_DECLS