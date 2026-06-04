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
#include <cstddef>
#define __GLIB_H_INSIDE__
#include <glibconfig.h>
#include <utility>

namespace ccompat
{

  namespace details
{

  template<typename T>
    struct __st_length_default { static constexpr T value = 0; };

  template<typename T>
    struct __st_length_default<T*> { static constexpr T* value = nullptr; };
}

  template<typename T, T _sentinel = details::__st_length_default<T>::value>
  [[gnu::always_inline]] [[gnu::pure]]
  static inline constexpr size_t _st_length (T* ar) noexcept G_GNUC_PURE;

  template<typename T, T _sentinel = details::__st_length_default<T>::value>
  [[gnu::always_inline]] [[gnu::pure]]
  static inline constexpr std::pair<bool, size_t> _st_length_cmp (T* ar1, T* ar2) noexcept G_GNUC_PURE;
}

template<typename T, T _sentinel>
[[gnu::always_inline]] [[gnu::pure]]
static inline constexpr size_t ccompat::_st_length (T* ar) noexcept
{

  size_t i; for (i = 0; _sentinel != ar [i]; ++i)
    { }
return i;
}

template<typename T, T _sentinel>
[[gnu::always_inline]] [[gnu::pure]]
static inline constexpr std::pair<bool, size_t> ccompat::_st_length_cmp (T* ar1, T* ar2) noexcept
{

  size_t i; for (i = 0; TRUE; ++i)
    {

      if (_sentinel == ar1 [i] || _sentinel == ar2 [i])
        return { ar1 [i] == ar2 [i], i };
    }
}