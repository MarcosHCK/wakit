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
#include <glib/gmacros.h>
#include <stdexcept>
#include <wakit/common/ffi/functioncfitype.h>

namespace ffi
{

  template<typename R, typename... Args> class function_cif
    {

      ffi_cif _cif;
      function_cif_types<R, Args ...> _cif_types;
    public:

      static constexpr function_cif_types<R, Args ...> cif_types;

      inline function_cif (ffi_abi abi = FFI_DEFAULT_ABI): _cif_types (cif_types)
        {

          constexpr auto nargs = sizeof... (Args);

          auto args = (ffi_type**) _cif_types.get_arguments ();
          auto ret = (ffi_type*) _cif_types.get_return ();
          int result;

          if (G_UNLIKELY (FFI_OK != (result = ffi_prep_cif (&_cif, abi, nargs, ret, args))))
            throw std::runtime_error ("can not create ffi_cif (code " + std::to_string (result) + ")");
        }

      inline constexpr const ffi_cif* get_cif () const noexcept
        { return &_cif; }
    };
}