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
#include <core/appbus/postablecollection.h>

struct _Entry
{

  guint post_id;
  WakitIPostable* postable;
};

static gint compare (struct _Entry* a, struct _Entry* b)
{

  auto a_ = (guintptr) (void*) a->postable;
  auto b_ = (guintptr) (void*) b->postable;

return a_ > b_ ? 1 : (a_ == b_ ? 0 : -1);
}

gboolean wakit_app_bus_postable_collection_del_impl (GArray* ar, WakitIPostable* postable, gboolean touched, guint* out_post_id)
{

  gboolean found;
  struct _Entry target = { .post_id = 0, .postable = postable };

  if (touched)
    g_array_sort (ar, (GCompareFunc) compare);

  if (guint index; ! (found = g_array_binary_search (ar, &target, (GCompareFunc) compare, &index)))

    (nullptr == out_post_id) ? NULL : (*out_post_id = 0);
  else
    {

      (nullptr == out_post_id) ? NULL : (*out_post_id = g_array_index (ar, _Entry, index).post_id);
      g_array_remove_index (ar, index);
    }
return found;
}