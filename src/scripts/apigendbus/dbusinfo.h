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

class dbus_info
{

  void* _p_data = nullptr;
public:

  ~dbus_info ();
  dbus_info (const dbus_info&) = delete;

  inline dbus_info () noexcept: _p_data ()
    { }

  inline dbus_info (void* __p_data) noexcept: _p_data (__p_data)
    { }

  inline dbus_info (dbus_info&& o) noexcept: _p_data (o._p_data)
    { o._p_data = nullptr; }

  inline void* operator* () const noexcept
    {

    return _p_data;
    }

  inline dbus_info& operator= (dbus_info&& o) noexcept
    {

      this->~dbus_info ();
      std::swap (o._p_data, this->_p_data);
    return *this;
    }

  template<typename... Args>
    requires std::is_constructible_v<dbus_info, Args ...>

  inline dbus_info& operator= (Args&&... args) noexcept (std::is_nothrow_constructible_v<dbus_info, Args ...>)
    {

      (*this) = dbus_info (std::forward<Args> (args) ...);
    return *this;
    }
};