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
#include <json-glib/json-glib.h>

namespace json
{

  typedef gpointer (*TakePointerFunc) (GType, JsonNode*);

  gpointer take_pointer_for_boxed (GType g_type, JsonNode* node) noexcept;
  gpointer take_pointer_for_object (GType g_type, JsonNode* node) noexcept;

  static inline constexpr TakePointerFunc take_pointer_for_type (GType g_type) noexcept
    {

      if (g_type_is_a (g_type, G_TYPE_BOXED))
        return (TakePointerFunc) json_boxed_deserialize;

      else if (g_type_is_a (g_type, G_TYPE_OBJECT))
        return (TakePointerFunc) json_gobject_deserialize;

      else
        g_error ("can not take pointer for type %s", g_type_name (g_type));
    }
}