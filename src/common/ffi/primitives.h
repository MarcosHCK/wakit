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
#include <cstdint>
#include <ffi.h>

namespace ffi
{

  template<typename T>
  struct ffi_type_for_primitive { static inline constexpr ffi_type* type = nullptr; };

  template<> struct ffi_type_for_primitive<void> { static inline constexpr ffi_type* type = &ffi_type_void; };
  template<> struct ffi_type_for_primitive<int8_t> { static inline constexpr ffi_type* type = &ffi_type_sint8; };
  template<> struct ffi_type_for_primitive<uint8_t> { static inline constexpr ffi_type* type = &ffi_type_uint8; };
  template<> struct ffi_type_for_primitive<int16_t> { static inline constexpr ffi_type* type = &ffi_type_sint16; };
  template<> struct ffi_type_for_primitive<uint16_t> { static inline constexpr ffi_type* type = &ffi_type_uint16; };
  template<> struct ffi_type_for_primitive<int32_t> { static inline constexpr ffi_type* type = &ffi_type_sint32; };
  template<> struct ffi_type_for_primitive<uint32_t> { static inline constexpr ffi_type* type = &ffi_type_uint32; };
  template<> struct ffi_type_for_primitive<int64_t> { static inline constexpr ffi_type* type = &ffi_type_sint64; };
  template<> struct ffi_type_for_primitive<uint64_t> { static inline constexpr ffi_type* type = &ffi_type_uint64; };
  template<> struct ffi_type_for_primitive<float> { static inline constexpr ffi_type* type = &ffi_type_float; };
  template<> struct ffi_type_for_primitive<double> { static inline constexpr ffi_type* type = &ffi_type_double; };
  template<> struct ffi_type_for_primitive<long double> { static inline constexpr ffi_type* type = &ffi_type_longdouble; };
}