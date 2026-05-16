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
#include <common/ffi/functioncfi.h>
#include <functional>
#include <type_traits>

namespace ffi
{

  static_assert (FFI_CLOSURES, "ffi closures are not supported");

  template<typename R, typename... Args> class function
    {

      typedef R (*codeloc_t) (Args ...);

      codeloc_t _codeloc = nullptr;
      ffi_closure* _closure;
      function_cif<R, Args ...> _function_cif;
      std::function<R (Args ...)> _target;

      template<typename T>
      [[gnu::always_inline]]
      static inline std::remove_reference_t<T>* cast (void* arg) noexcept
        {

          if constexpr (! std::is_reference_v<T>)

            return (std::remove_reference_t<T>*) (ffi_arg*) arg;
          else
            return *(std::remove_reference_t<T>**) (ffi_arg*) arg;
        }

      static void marshaller (ffi_cif* cif, void* p_return, void** p_args, void* p_this) noexcept
        {

          marshaller_helper (cif, p_return, p_args, p_this, std::make_integer_sequence<unsigned, sizeof... (Args)> ());
        }

      template<unsigned... Is>
      [[gnu::always_inline]]
      static inline void marshaller_helper (ffi_cif* cif, void* p_return, void** p_args, void* p_this, std::integer_sequence<unsigned, Is ...> const&) noexcept
        {

          if constexpr (std::same_as<R, void>)

            ((function*) p_this)->_target (*cast<Args> (p_args [Is]) ...);
          else

            if constexpr (! std::is_reference_v<R>)

              *((std::remove_reference_t<R>*) (ffi_arg*) p_return) = ((function*) p_this)->_target (*cast<Args> (p_args [Is]) ...);
            else
              *((std::remove_reference_t<R>**) (ffi_arg*) p_return) = &((function*) p_this)->_target (*cast<Args> (p_args [Is]) ...);
        }

    public:

      typedef typename std::function<R (Args ...)> function_type;

      inline ~function ()
        {

          if (nullptr != _closure)
            ffi_closure_free (_closure);
        }

      function () = delete;
      function (const function&) = delete;

      inline function (function&& o) noexcept (std::is_nothrow_move_constructible_v<function_type>):
          _codeloc (o._codeloc),
          _closure (o._closure),
          _function_cif (std::move (o._function_cif)),
          _target (std::move (o._target))
        { o._codeloc = NULL; o._closure = NULL; }

      template<typename Fn>
        requires (std::is_invocable_r_v<R, Fn, Args ...>)
      inline function (Fn&& callable): _function_cif (), _target (std::move (callable))
        {

          if (G_UNLIKELY (NULL == (_closure = (ffi_closure*) ffi_closure_alloc (sizeof (ffi_closure), (void**) &_codeloc))))
            throw std::runtime_error ("can not allocate ffi_closure");

          int result;
          auto cif = (ffi_cif*) _function_cif.get_cif ();

          if (G_UNLIKELY (FFI_OK != (result = ffi_prep_closure_loc (_closure, cif, marshaller, this, (void*) _codeloc))))
            throw std::runtime_error ("can not create ffi_closure (code " + std::to_string (result) + ")");
        }

      inline constexpr codeloc_t get_codeloc () const noexcept
        { return _codeloc; }
    };
}