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
#include <extension/binding/signalable.h>
#include <map>

static void emit_single (gpointer key G_GNUC_UNUSED, JSCValue* value, GPtrArray* params)
{

  g_object_unref (jsc_value_function_callv (value, params->len, (JSCValue**) params->pdata));
}

void wakit_binding_isignalable_hub_emit_group (GTree* handlers, GPtrArray* params)
{

  g_tree_foreach (handlers, (GTraverseFunc) emit_single, params);
}

struct _EmitVrData
{

  std::map<guintptr, GPtrArray*> map;
  GVariant* params;

  inline _EmitVrData (GVariant* _params) noexcept:
      map (),
      params (_params)
    { }

  inline ~_EmitVrData () noexcept
    {

      for (const auto& [ _, ar ]: map)
        g_ptr_array_unref (ar);
    }

  inline GPtrArray* to_jsc_values (JSCContext* context) const noexcept
    {
      return wakit_marshalling_container_to_jsc_values (context, params);
    }
};

static void emit_vr_single (gpointer key G_GNUC_UNUSED, JSCValue* value, struct _EmitVrData* data)
{

  auto context = jsc_value_get_context (value);
  auto& map = data->map;
  auto params = (GPtrArray*) nullptr;

  if (auto iter = map.find ((guintptr) context); iter != map.end ())

    params = iter->second;
  else
    params = map.emplace ((guintptr) context, data->to_jsc_values (context)).first->second;

return emit_single (key, value, params);
}

void wakit_binding_isignalable_hub_emit_vr_group (GTree* handlers, GVariant* params)
{

  struct _EmitVrData data (params);
  g_tree_foreach (handlers, (GTraverseFunc) emit_vr_single, &data);
}