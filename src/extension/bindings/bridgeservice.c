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
#include <glib.h>

static __inline gchar** _g_strndupv (gchar** strv, guint length)
{

  if (NULL == strv)
    return NULL;

  gchar** ar = g_new (gchar*, 1 + length);

  for (guint i = 0; i < length; ++i)
    ar [i] = g_strdup (strv [i]);

return (ar [length] = NULL, ar);
}