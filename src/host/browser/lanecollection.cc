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
#include <algorithm>
#include <host/browser/lanecollection.h>

static gint compare (WakitExtensionLane* a, WakitExtensionLane* b)
{

  int balance;

  if (a == b)
    return 0;

  else if (0 != (balance = g_strcmp0 (wakit_extension_lane_get_interface_name (a),
                                      wakit_extension_lane_get_interface_name (b))))
    return balance;

  else if (0 != (balance = g_strcmp0 (wakit_extension_lane_get_object_path (a),
                                      wakit_extension_lane_get_object_path (b))))
    return balance;

  else if (0 != (balance = g_strcmp0 (wakit_extension_lane_get_property_name (a),
                                      wakit_extension_lane_get_property_name (b))))
    return balance;

  else if (0 != (balance = g_strcmp0 (wakit_extension_lane_get_type_name (a),
                                      wakit_extension_lane_get_type_name (b))))
    return balance;

return balance;
}

void wakit_browser_lane_collection_del_impl (GPtrArray* ar, WakitExtensionLane* lane, gboolean needs_sort)
{

  if (needs_sort)
    g_ptr_array_sort (ar, (GCompareFunc) compare);

  auto begin = (WakitExtensionLane**) ar->pdata;
  auto end = (WakitExtensionLane**) (begin + ar->len);

  if (auto iter = std::lower_bound (begin, begin + ar->len, lane, compare); iter != end && compare (lane, *iter))
    g_ptr_array_remove_index (ar, (iter - begin) / sizeof (WakitExtensionLane*));
}

[[gnu::always_inline]]
static inline GVariant* g_variant_new_maybe_string (const gchar* str)
{

  if (nullptr == str)

    return g_variant_new_maybe (G_VARIANT_TYPE ("s"), nullptr);
  else
    return g_variant_new_maybe (G_VARIANT_TYPE ("s"), g_variant_new_string (str));
}

GVariant* wakit_browser_lane_collection_serialize_impl (GPtrArray* ar)
{

  auto type = G_VARIANT_TYPE ("a(ssmsms)");
  auto builder = GVariantBuilder G_VARIANT_BUILDER_INIT (type);

  for (decltype (ar->len) i = 0; i < ar->len; ++i)
    {

      const auto lane = ((WakitExtensionLane**) ar->pdata) [i];

      g_variant_builder_open (&builder, G_VARIANT_TYPE ("(ssmsms)"));

      g_variant_builder_add_value (&builder, g_variant_new_string (wakit_extension_lane_get_interface_name (lane)));
      g_variant_builder_add_value (&builder, g_variant_new_string (wakit_extension_lane_get_object_path (lane)));
      g_variant_builder_add_value (&builder, g_variant_new_maybe_string (wakit_extension_lane_get_property_name (lane)));
      g_variant_builder_add_value (&builder, g_variant_new_maybe_string (wakit_extension_lane_get_type_name (lane)));
      g_variant_builder_close (&builder);
    }
return g_variant_builder_end (&builder);
}