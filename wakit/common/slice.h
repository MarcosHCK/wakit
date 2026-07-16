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
#include <glib.h>
#include <new>
#include <utility>

template<typename T,
         typename A = T>
static inline void g_slice_free_ (A* object) noexcept (std::is_nothrow_destructible_v<T>)
{

  ((T*) object)->~T ();
  g_slice_free (T, (gpointer) object);
}

template<typename T,
         typename... Args,
         typename = std::enable_if_t<std::is_constructible_v<T, Args ...>>>
static inline T* g_slice_new_ (Args&&... args) noexcept (std::is_nothrow_constructible_v<T, Args ...>)
{

  auto mem = g_slice_alloc (sizeof (T));
  auto ptr = new (mem) T (std::forward<Args> (args) ...);
return ptr;
}

template<typename T,
         typename... Args,
         typename = std::enable_if_t<std::is_constructible_v<T, Args ...>>>
static inline T* g_slice_new0_ (Args&&... args) noexcept (std::is_nothrow_constructible_v<T, Args ...>)
{

  auto mem = g_slice_alloc0 (sizeof (T));
  auto ptr = new (mem) T (std::forward<Args> (args) ...);
return ptr;
}