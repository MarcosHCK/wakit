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
#include <climits>
#include <concepts>
#include <cstddef>

namespace bits
{

  template<size_t bytes>
    struct is_2pow { static inline constexpr bool value = 2 > bytes || 0 == (bytes & 1); };
  template<size_t bytes>
    static inline constexpr bool is_2pow_v = is_2pow<bytes>::value;

  template<size_t bytes, typename T = unsigned> requires (is_2pow_v<bytes>)
    struct log2 { static inline constexpr unsigned value = 1 + log2<bytes / 2, T>::value; };
  template<typename T>
    struct log2<1, T> { static inline constexpr unsigned value = 0; };
  template<size_t bytes, typename T = unsigned> requires (is_2pow_v<bytes>)
    static inline constexpr const unsigned log2_v = log2<bytes, T>::value;

  template<size_t to, typename T>
  [[gnu::always_inline]]
  static inline constexpr T align_upto (T n) noexcept
    {

    return ((n + (to - 1)) >> log2_v<to, T>) << log2_v<to, T>;
    }

  template<size_t n, size_t to>
    static inline constexpr const size_t align_upto_v = align_upto<to> (n);

  template<std::unsigned_integral T, int _By>
  [[gnu::always_inline]]
  static inline constexpr T rot (T value) noexcept
    {

      constexpr int bits = sizeof (T) * CHAR_BIT;
      static_assert (bits >= _By);

    return (value << _By) | (value << (bits - _By));
    }
}