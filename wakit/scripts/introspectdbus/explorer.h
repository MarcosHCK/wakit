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
#include <generator>
#include <memory>
#include <span>
#include <string>

class explorer
{

  void* _p_binary;
public:

  using symbol = std::tuple<const std::string&, uint64_t, size_t>;

  ~explorer ();

  explorer (explorer&&) = delete;
  explorer (const explorer&) = delete;
  explorer (const std::string& filename);

  std::generator<symbol> suffixed_symbols (const std::string& suffix);

  template<typename T,
           size_t n_bytes = sizeof (T)>
  inline T* read_trivial_array (uint64_t va, size_t length) const
    {

      auto dst = (uint8_t*) malloc (n_bytes * length);
      auto src = read_va (va, n_bytes * length);

      std::uninitialized_copy (src.begin (), src.end (), dst);
    return (T*) dst;
    }

  template<typename T,
           size_t n_bytes = sizeof (T)>
  inline std::tuple<T*, size_t> read_trivial_array_with_sentinel (uint64_t va, T sentinel) const
    {

      auto siz = n_bytes;
      auto src = read_va (va, siz);

      for (; sentinel != *((T*) &*(src.end () - n_bytes)); siz += n_bytes, src = read_va (va, siz))
        continue;

      uint8_t* dst;
      std::uninitialized_copy (src.begin (), src.end (), dst = (uint8_t*) malloc (siz));

    return { (T*) dst, (siz / n_bytes) - 1 };
    }

  template<typename T,
           size_t n_bytes = sizeof (T)>
  inline void read_trivial_object (uint64_t va, T& result) const
    {

      auto dst = std::span ((uint8_t*) &result, n_bytes);
      auto src = read_va (va, n_bytes);

      std::uninitialized_copy (src.begin (), src.end (), dst.begin ());
    }

  inline char* read_string (uint64_t va) const
    {

      auto [ str, _ ] = read_trivial_array_with_sentinel (va, '\0');
    return str;
    }

  std::span<const uint8_t> read_va (uint64_t va, size_t n_bytes) const;
};