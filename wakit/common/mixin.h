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
#include <glib.h>
#include <type_traits>

#define _mixin_decl(type,name,static_slots) \
 ; \
  type* name = NULL; \
  type* __mixin_dyn_##name = NULL; \
  type __mixin_stat_##name [(static_slots)];

#define _mixin_alloc(type,name,slots) (G_GNUC_EXTENSION ({ \
 ; \
  gsize __slots = ((slots)); \
  name = G_N_ELEMENTS (__mixin_stat_##name ) < __slots ? & __mixin_stat_##name [0] \
                                                       : (__mixin_dyn_##name = g_new (type, __slots)); \
 }))

#define _mixin_new(type,name,static_slots,slots) \
 ; \
  _mixin_decl (type, name, static_slots); \
  _mixin_alloc (type, name, slots);

#define _mixin_free(type,name) \
 ; \
  g_free (__mixin_dyn_##name );

#define _mixin_free_(type,name,slots,...) (G_GNUC_EXTENSION ({ \
 ; \
  gsize __slots = ((slots)); \
  for (gsize __i = 0; __i < __slots; ++__i) \
    { type* slot = & name [__i]; G_STMT_START { __VA_ARGS__; } G_STMT_END; } \
  _mixin_free (type,name) \
 }))

#ifdef G_CXX_STD_VERSION
// C++

#undef _mixin_decl
#define _mixin_decl(type,name,static_slots) \
 ; \
  type* name = NULL; \
  typedef _mixin<type, ((static_slots))> __mixin_type_##name ; \

#undef _mixin_alloc
#define _mixin_alloc(type,name,slots) \
 ; \
  __mixin_type_##name __mixin_##name (((slots))); \
  name = __mixin_##name .actual (); \

#undef _mixin_free
#define _mixin_free(type,name)

template<typename T, size_t n_static_slots> class _mixin
{

  T* _dynamic_slots = nullptr;
  T _static_slots [n_static_slots];

  size_t _slots;
  T* _actual;

  T* alloc_actual (size_t slots)
    {

      return n_static_slots >= slots
        ? _static_slots
        : (_dynamic_slots = (T*) g_slice_alloc0 (_slots * sizeof (T)), _dynamic_slots);
    }

public:

  inline ~_mixin ()
    {

      for (decltype (_slots) i = 0; i < _slots; ++i)
        (&_actual [i])->~T ();

      if (nullptr != _dynamic_slots)
        g_slice_free1 (_slots * sizeof (T), (void*) _dynamic_slots);
    }

  inline _mixin (size_t slots) noexcept: _slots (slots), _actual (alloc_actual (slots))
    {
    }

  template<typename U = T,
           typename = std::enable_if_t<std::is_default_constructible_v<U>>>
  inline _mixin (size_t slots, int) noexcept: _slots (slots), _actual (alloc_actual (slots))
    {

      for (decltype (_slots) i = 0; i < _slots; ++i)
        new (&_actual [i]) T ();
    }

  inline T* actual () const noexcept { return _actual; }
};

#endif // G_CXX_STD_VERSION