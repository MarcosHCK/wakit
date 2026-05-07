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
#include <algorithm>
#include <common/constpairs.h>

namespace constmap
{

  template<typename First, typename Second, size_t N> class map
    {

      std::array<std::pair<First, Second>, N> _pairs;

      static constexpr bool equal_compare (const std::pair<First, Second>& a, const First& b)
        {
          return a.first == b;
        }

      static constexpr bool find_compare (const std::pair<First, Second>& a, const First& b)
        {
          return a.first < b;
        }

      static constexpr bool key_compare (const std::pair<First, Second>& a, const std::pair<First, Second>& b)
        {
          return a.first < b.first;
        }

    public:

      inline constexpr map (std::array<std::pair<First, Second>, N> pairs) noexcept: _pairs (std::move (pairs))
        {
          std::sort (_pairs.begin (), _pairs.end (), key_compare);
        }

      inline constexpr decltype (_pairs)::const_iterator begin () const noexcept
        {
          return _pairs.cbegin ();
        }

      inline constexpr decltype (_pairs)::const_iterator end () const noexcept
        {
          return _pairs.cend ();
        }

      inline constexpr decltype (_pairs)::const_iterator find (const First& key) const noexcept
        {

          if (auto iter = std::lower_bound (_pairs.cbegin (), _pairs.cend (), key, find_compare);
              iter != _pairs.cend () && equal_compare (*iter, key))

            return iter;
          else
            return _pairs.cend ();
        }
    };

  template<typename First, typename Second, size_t N>
  inline constexpr map<First, Second, N> make_constmap (const std::pair<First, Second> (&pairs) [N])
    {
      return map<First, Second, N> (constpairs::__make_array (pairs));
    }
}