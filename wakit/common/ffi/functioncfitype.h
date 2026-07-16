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
#include <utility>
#include <wakit/common/ffi/primitives.h>

namespace ffi
{

  template<typename R, typename... Args> class function_cif_types
    {

      ffi_type* _arguments [sizeof... (Args)];
      ffi_type* _return;

      template<typename T>
      [[gnu::always_inline]]
      static inline constexpr ffi_type* get_for_type () noexcept
        {
      
          if constexpr (std::is_reference_v<T> || std::is_pointer_v<T>)
            return &ffi_type_pointer;

          else if constexpr (nullptr != ffi_type_for_primitive<T>::type)
            return ffi_type_for_primitive<T>::type;

          else
            static_assert (false, "can not translate this type");
        }

      static inline constexpr void get_for_types (ffi_type* (&args) [sizeof... (Args)])
        {

          get_for_types_helper (args, std::make_integer_sequence<unsigned, sizeof... (Args)> ());
        }

      template<unsigned... Is>
      static inline constexpr void get_for_types_helper (ffi_type* (&args) [sizeof... (Args)], std::integer_sequence<unsigned, Is ...> const&)
        {

          (void) ((args [Is] = get_for_type<Args> ()), ...);
        }

    public:

      inline constexpr function_cif_types () noexcept: _arguments { },
                                                      _return (get_for_type<R> ())
        {
          get_for_types (_arguments);
        }

      inline constexpr const ffi_type** get_arguments () const noexcept
        { return (const ffi_type**) _arguments; }

      inline constexpr const ffi_type* get_return () const noexcept
        { return (const ffi_type*) _return; }
    };
}