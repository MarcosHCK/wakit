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
#define __GLIB_H_INSIDE__
#include <glibconfig.h>
#include <ranges>
#include <wakit/common/bits.h>
#include <wakit/common/hashing.h>

#ifndef G_GUINT32_CONSTANT
# define G_GUINT32_CONSTANT(val) val##u;
#endif // G_GUINT32_CONSTANT

namespace hashing
{

  template<std::unsigned_integral T>
  [[gnu::always_inline]] [[gnu::pure]]
  static inline constexpr T mix (T key_a, T key_b, T salt) noexcept G_GNUC_PURE;

  template<std::unsigned_integral T, std::integral D,
           std::ranges::view V>
  requires std::same_as<D, std::ranges::range_value_t<V>>
  [[gnu::always_inline]] [[gnu::pure]]
  static inline constexpr T djb (V&& view) noexcept G_GNUC_PURE;

  template<std::unsigned_integral T, std::integral D,
           std::ranges::view V>
  requires std::same_as<D, std::ranges::range_value_t<V>>
  [[gnu::always_inline]] [[gnu::pure]]
  static inline constexpr T fnv_1a (V&& view) noexcept G_GNUC_PURE;

  template<std::unsigned_integral T, std::integral D,
           std::ranges::view V>
  requires std::same_as<D, std::ranges::range_value_t<V>>
  [[gnu::always_inline]] [[gnu::pure]]
  static inline constexpr T murmur2 (V&& view) noexcept G_GNUC_PURE;

  namespace details
{

  template<std::integral T>
    struct __djb_magic { static inline constexpr bool exists = false; };

  template<>
    struct __djb_magic<uint32_t> { static inline constexpr bool exists = true;
                                   static inline constexpr uint32_t value = G_GUINT32_CONSTANT (5381); };

  template<>
    struct __djb_magic<uint64_t> { static inline constexpr bool exists = true;
                                   static inline constexpr uint64_t value = G_GUINT64_CONSTANT (14695981039346656037); };

  template<std::integral T>
    struct __fnv_1a_magics { static inline constexpr bool exists = false; };

  template<>
    struct __fnv_1a_magics<uint8_t> { static inline constexpr bool exists = true;
                                       static inline constexpr uint8_t basis = 101;
                                       static inline constexpr uint8_t prime = 251; };

  template<>
    struct __fnv_1a_magics<uint16_t> { static inline constexpr bool exists = true;
                                       static inline constexpr uint16_t basis = 1313;
                                       static inline constexpr uint16_t prime = 40343; };

  template<>
    struct __fnv_1a_magics<uint32_t> { static inline constexpr bool exists = true;
                                       static inline constexpr uint32_t basis = G_GUINT32_CONSTANT (2166136261);
                                       static inline constexpr uint32_t prime = G_GUINT32_CONSTANT (16777619); };

  template<>
    struct __fnv_1a_magics<uint64_t> { static inline constexpr bool exists = true;
                                       static inline constexpr uint64_t basis = G_GUINT64_CONSTANT (14695981039346656037);
                                       static inline constexpr uint64_t prime = G_GUINT64_CONSTANT (1099511628211); };

  template<std::integral T>
    struct __murmur2_magics { static inline constexpr bool exists = false; };

  template<>
    struct __murmur2_magics<uint32_t> { static inline constexpr bool exists = true;
                                        static inline constexpr uint32_t factor = G_GUINT32_CONSTANT (0x5bd1e995);
                                        static inline constexpr uint32_t shift = 24; };

  template<>
    struct __murmur2_magics<uint64_t> { static inline constexpr bool exists = true;
                                        static inline constexpr uint64_t factor = G_GUINT64_CONSTANT (0xc6a4a7935bd1e995);
                                        static inline constexpr uint64_t shift = 47; };
} }

template<std::unsigned_integral T>
[[gnu::always_inline]] [[gnu::pure]]
static inline constexpr T hashing::mix (T key_a, T key_b, T salt) noexcept
{

  key_a -= salt; key_a ^= bits::rot<T, 4> (salt); salt += key_b;
  key_b -= key_a; key_b ^= bits::rot<T, 6> (key_a); key_a += salt;
  salt -= key_b; salt ^= bits::rot<T, 8> (key_b); key_b += key_a;
  key_a -= salt; key_a ^= bits::rot<T, 16> (salt); salt += key_b;
  key_b -= key_a; key_b ^= bits::rot<T, 19> (key_a); key_a += salt;
  salt -= key_b; salt ^= bits::rot<T, 4> (key_b);
return salt;
}

template<std::unsigned_integral T, std::integral D,
         std::ranges::view V>
requires std::same_as<D, std::ranges::range_value_t<V>>
[[gnu::always_inline]] [[gnu::pure]]
static inline constexpr T hashing::djb (V&& view) noexcept
{

  static_assert (hashing::details::__djb_magic<T>::exists, "DjB magic value is not defined for this type");

  T hash = details::__djb_magic<T>::value; for (const D item: view)
    hash = ((hash << 5) + hash) + item;

return hash;
}

template<std::unsigned_integral T, std::integral D,
         std::ranges::view V>
requires std::same_as<D, std::ranges::range_value_t<V>>
[[gnu::always_inline]] [[gnu::pure]]
static inline constexpr T hashing::fnv_1a (V&& view) noexcept
{

  static_assert (hashing::details::__fnv_1a_magics<T>::exists, "FNV-1a magic values are not defined for this type");

  T hash = details::__fnv_1a_magics<T>::basis; for (const D item: view)
    hash = (hash ^ (T) item) * details::__fnv_1a_magics<T>::prime;

return hash;
}

template<std::unsigned_integral T, std::integral D,
         std::ranges::view V>
requires std::same_as<D, std::ranges::range_value_t<V>>
[[gnu::always_inline]] [[gnu::pure]]
static inline constexpr T hashing::murmur2 (V&& view) noexcept
{

  static_assert (hashing::details::__murmur2_magics<T>::exists, "Murmur2 magic values are not defined for this type");

  T hash = 0,
    piece = 0;
  unsigned left = sizeof (T);

  constexpr auto mask = ((size_t) 1 << CHAR_BIT) - 1;

  for (D item: view)
    {

    for (unsigned remain = sizeof (D); 0 < remain;)
      {

        auto take = std::min (left, remain);

        for (unsigned i = 0; i < take; ++i)
          {

            piece <<= CHAR_BIT;
            piece |= (T) (item & mask);

            if constexpr (sizeof (D) > 1)
              item >>= CHAR_BIT;
          }

        if (remain -= take; 0 == (left -= take))
          {

            piece *= hashing::details::__murmur2_magics<T>::factor;
            piece ^= piece >> hashing::details::__murmur2_magics<T>::shift;
            piece *= hashing::details::__murmur2_magics<T>::factor;

            hash ^= piece;
            hash *= hashing::details::__murmur2_magics<T>::factor;

            left = sizeof (T);
            piece = 0;
          }
    } }

  if (0 < (sizeof (T) - left))
    {

      hash ^= piece;
      hash *= hashing::details::__murmur2_magics<T>::factor;
    }

  hash ^= hash >> hashing::details::__murmur2_magics<T>::shift;
  hash *= hashing::details::__murmur2_magics<T>::factor;
  hash ^= hash >> hashing::details::__murmur2_magics<T>::shift;
return hash;
}