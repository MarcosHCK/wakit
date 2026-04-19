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
#include <extension/utility/marshalling.h>

G_BEGIN_DECLS

  G_GNUC_INTERNAL void wakit_binding_isignalable_hub_emit_group (GTree* handlers, GPtrArray* params);
  G_GNUC_INTERNAL void wakit_binding_isignalable_hub_emit_vr_group (GTree* handlers, GVariant* params);

G_END_DECLS