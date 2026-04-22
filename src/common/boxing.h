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
#include <glib-object.h>
#include <utility>

namespace boxing
{

  template<typename T>
  using box_copy_func = T* (*) (T*);

  template<typename T>
  using box_free_func = void (*) (T*);

  template<typename T,
           box_free_func<T> _free_func = nullptr>
  class destructible_box;

  template<typename T,
           box_copy_func<T> _copy_func = nullptr,
           box_free_func<T> _free_func = nullptr,
           typename = std::enable_if_t<nullptr != _free_func>>
  class copyable_box;

  using bytes = copyable_box<GBytes, g_bytes_ref, g_bytes_unref>;

  namespace details
    {

      template<typename T>
      static void _g_free (T* object) noexcept { return g_free ((void*) object); }

      template<typename T>
      static T* _g_object_ref (T* object) noexcept { return g_object_ref (object); }

      template<typename T>
      static void _g_object_unref (T* object) noexcept { return g_object_unref (object); }
    }

  template<typename T>
  static void _free_with_delete (T* object) noexcept { delete object; }

  template<typename T>
  using freeable = destructible_box<T, details::_g_free<T>>;

  using string = freeable<gchar>;

  template<typename T>
  using object = copyable_box<T, details::_g_object_ref<T>, details::_g_object_unref<T>>;
}

template<typename T,
         boxing::box_free_func<T> _free_func>
class boxing::destructible_box
{

  T* _value = nullptr;

  void destruct () noexcept
    {

      if constexpr (nullptr == _free_func)

        _value = nullptr;
      else

        if (nullptr != _value)
          _value = (_free_func (_value), nullptr);
    }

public:

  inline ~destructible_box ()
    {
      destruct ();
    }

  destructible_box (const destructible_box&) = delete;
  destructible_box& operator= (const destructible_box&) = delete;

  inline destructible_box () noexcept
    { }

  inline destructible_box (T* value) noexcept: _value (value)
    { }

  inline destructible_box (destructible_box&& o) noexcept: _value (o._value)
    { o._value = nullptr; }

  inline T* operator* () const noexcept { return _value; }

  inline T* steal () noexcept
    {
      auto value = _value;
    return (_value = nullptr, value);
    }

  inline destructible_box& operator= (T* _new_value) noexcept
    {

      _value = (({ if (nullptr != _value) destruct (); }), _new_value);
    return *this;
    }

  inline destructible_box& operator= (destructible_box&& _new_value) noexcept
    {

      _value = (({ if (nullptr != _value) destruct (); }), _new_value._value);
    return (_new_value._value = nullptr, *this);
    }
};

template<typename T,
         boxing::box_copy_func<T> _copy_func,
         boxing::box_free_func<T> _free_func,
         typename>
class boxing::copyable_box: public destructible_box<T, _free_func>
{
public:

  inline copyable_box () noexcept: destructible_box<T, _free_func> ()
    { }

  inline copyable_box (T* value) noexcept: destructible_box<T, _free_func> (value)
    { }

  inline copyable_box (const copyable_box& o) noexcept: destructible_box<T, _free_func> (_copy_func (*o))
    { }

  inline copyable_box& operator= (T* _new_value) noexcept
    {

      destructible_box<T, _free_func>::operator= ((T*) _new_value);
    return *this;
    }

  inline copyable_box& operator= (copyable_box&& o) noexcept
    {

      destructible_box<T, _free_func>::operator= (std::move (o));
    return *this;
    }

  inline copyable_box& operator= (const copyable_box& o) noexcept
    {

      destructible_box<T, _free_func>::operator= ((T*) _copy_func (*o));
    return *this;
    }
};