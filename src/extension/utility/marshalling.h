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
#include <glib.h>
#include <jsc/jsc.h>

G_BEGIN_DECLS

  GPtrArray* wakit_marshalling_container_to_jsc_values (JSCContext* context, GVariant* variant);
  GVariant* wakit_marshalling_jsc_value_to_variant (JSCContext* context, const GVariantType* type, JSCValue* value);
  GVariant* wakit_marshalling_jsc_values_to_variant (JSCContext* context, const GVariantType* type, GPtrArray* values);
  JSCValue* wakit_marshalling_variant_to_jsc_value (JSCContext* context, GVariant* variant);

G_END_DECLS