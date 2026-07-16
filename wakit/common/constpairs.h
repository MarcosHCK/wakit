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
#include <array>

namespace constpairs
{

  template<typename First, typename Second, int N, int... Is>
  static inline constexpr std::array<std::pair<First, Second>, N> __make_array_helper (const std::pair<First, Second> (&pairs) [N],
                                                                                           std::integer_sequence<int, Is ...> const&)
    {
      return std::array<std::pair<First, Second>, N> { pairs [Is] ... };
    }

  template<typename First, typename Second, int N>
  static inline constexpr std::array<std::pair<First, Second>, N> __make_array (const std::pair<First, Second> (&pairs) [N])
    {
      return __make_array_helper (pairs, std::make_integer_sequence<int, N> ());
    }
}