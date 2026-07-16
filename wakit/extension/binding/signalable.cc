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
#include <map>
#include <wakit/extension/binding/signalable.h>

static G_DEFINE_QUARK (wakit-binding-isignalable-hub-emit-single-invoker-quark,
                       invoker);

[[gnu::always_inline]]
static inline JSCValue* get_invoker (JSCContext* context)
{

  static const char code [] = "(f,a) =>"
    "f (...a)";

  auto invoker = (JSCValue*) nullptr;
  auto weakref = (JSCWeakValue*) g_object_get_qdata ((GObject*) context, invoker_quark ());

  if (G_UNLIKELY (NULL == weakref 
               || NULL == (invoker = jsc_weak_value_get_value (weakref))))
    {

      invoker = jsc_context_evaluate_with_source_uri (context, code, G_N_ELEMENTS (code) - 1,
        "wakit:///extension/binding/signalable.js", 1);

      weakref = jsc_weak_value_new (invoker);

      g_object_set_qdata_full ((GObject*) context, invoker_quark (), weakref, g_object_unref);
    }
return invoker;
}

static void emit_single (gpointer key G_GNUC_UNUSED, JSCValue* value, JSCValue* params)
{

  auto context = jsc_value_get_context (value);
  auto invoker = get_invoker (context);

  JSCValue* parameters [] = { value, params };

  g_object_unref (jsc_value_function_callv (invoker, G_N_ELEMENTS (parameters), parameters));
  g_object_unref (invoker);
}

void wakit_binding_isignalable_hub_emit_group (GTree* handlers, GPtrArray* params)
{

  g_tree_foreach (handlers, (GTraverseFunc) emit_single, params);
}

struct _EmitVrData
{

  std::map<guintptr, JSCValue*> map;
  GVariant* params;

  inline _EmitVrData (GVariant* _params) noexcept:
      map (),
      params (_params)
    { }

  inline ~_EmitVrData () noexcept
    {

      for (const auto& [ _, ar ]: map)
        g_object_unref (ar);
    }

  inline JSCValue* to_jsc_values (JSCContext* context) const noexcept
    {
      return wakit_marshalling_variant_to_jsc_value (context, params);
    }
};

static void emit_vr_single (gpointer key G_GNUC_UNUSED, JSCValue* value, struct _EmitVrData* data)
{

  auto context = jsc_value_get_context (value);
  auto& map = data->map;
  auto params = (JSCValue*) nullptr;

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