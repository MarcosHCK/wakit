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
#include <common/ffi/destroynotify.h>
#include <common/ffi/function.h>
#include <common/genericmap.h>
#include <common/json/takepointer.h>
#include <common/json/wakit-common-json.h>
#include <json-glib/json-glib.h>
#include <vector>

std::vector<ffi::function<GPtrArray*, JsonNode*>> _ptr_array_deserializers;
std::vector<ffi::function<JsonNode*, GPtrArray*>> _ptr_array_serializers;
generic_map::generic_map<1> _ptr_array_types;

[[gnu::always_inline]]
static GPtrArray* deserialize (JsonNode* node, GType a_type,
  json::TakePointerFunc take, GDestroyNotify notify)
{

  auto array = json_node_get_array (node);
  auto length = json_array_get_length (array);
  auto result = g_ptr_array_new_full (length, notify);

  for (decltype (length) i = 0; i < length; ++i)
    {

      auto element = json_array_get_element (array, i);
      auto pointer = take (a_type, element);

      g_ptr_array_add (result, pointer);
    }
return result;
}

[[gnu::always_inline]]
static std::function<GPtrArray* (JsonNode*)> deserialize_func (GType a_type)
{

  auto take = json::take_pointer_for_type (a_type);
  auto notify = wakit_ffi_destroy_notify_for_type (a_type);

return [=](JsonNode* node) { return deserialize (node, a_type, take, notify); };
}

static GType ensure (GType a_type) noexcept
{

  auto name = _ptr_array_types.build_name ("GPtrArray", a_type);

  auto type = g_boxed_type_register_static (name, (GBoxedCopyFunc) g_ptr_array_ref,
                                                  (GBoxedFreeFunc) g_ptr_array_unref);

  auto deserialize = _ptr_array_deserializers.emplace_back (deserialize_func (a_type)).get_codeloc ();

  json_boxed_register_deserialize_func (type, JSON_NODE_ARRAY, (JsonBoxedDeserializeFunc) deserialize);

return type;
}

GType wakit_json_generic_ptr_array_get_type (GType g_type)
{

  g_return_val_if_fail (g_type_is_a (g_type, G_TYPE_BOXED) || g_type_is_a (g_type, G_TYPE_OBJECT), G_TYPE_INVALID);

return _ptr_array_types.ensure_type (ensure, g_type);
}