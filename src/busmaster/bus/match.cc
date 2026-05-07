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
#include <busmaster/bus/match.h>

#define _g_free0(var) ((NULL == var) ? NULL : (var = (g_free (var), nullptr)))

void wakit_busmaster_bus_element_clear (WakitBusmasterBusMatchElement* element)
{

  g_printerr ("~Match.Element ()\n");
  _g_free0 (element->value);
}

gboolean wakit_busmaster_bus_match_equal_impl (WakitBusmasterBusMatchElement* a,
                                               WakitBusmasterBusMatchElement* b,
                                               guint n_elements)
{

  for (decltype (n_elements) i = 0; i < n_elements; ++i)
    {

      const auto& a_ = a [i];
      const auto& b_ = b [i];

      if (a_.argn != b_.argn || a_.type != b_.type || !g_str_equal (a_.value, b_.value))
        return FALSE;
    }
return TRUE;
}