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
#include <jsc/jsc.h>

static __inline void wakit_binding_isignalable_hub_emit_group (GTree* handlers, GPtrArray* params);
static __inline void wakit_binding_isignalable_hub_emit_single (gpointer key G_GNUC_UNUSED, JSCValue* value, GPtrArray* params);

static __inline void wakit_binding_isignalable_hub_emit_group (GTree* handlers, GPtrArray* params)
{

  g_tree_foreach (handlers, (GTraverseFunc) wakit_binding_isignalable_hub_emit_single, params);
}

static __inline void wakit_binding_isignalable_hub_emit_single (gpointer key G_GNUC_UNUSED, JSCValue* value, GPtrArray* params)
{

  g_object_unref (jsc_value_function_callv (value, params->len, (JSCValue**) params->pdata));
}