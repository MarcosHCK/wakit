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
#include <utility>

template<unsigned N> static void g_value_unset_ (GValue (&values) [N])
{

  for (std::remove_cvref_t<decltype (N)> i = 0; i < N; ++i)
    g_value_unset (&values [i]);
}

template<typename... Args,
         typename = std::enable_if_t<( std::is_same_v<Args, GValue*> && ... )>>
static void g_value_unset_ (Args&&... args)
{

return (g_value_unset (std::forward<Args> (args)), ...);
}