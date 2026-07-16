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
#include <gio/gio.h>
#include <iterator>
#include <ranges>
#include <wakit/scripts/introspectdbus/explorer.h>

class dbus_info_explorer: public explorer
{

public:

  inline dbus_info_explorer (const std::string& filename): explorer (filename)
    { }

  template<std::input_iterator Iterator>
    requires std::same_as<typename std::iterator_traits<Iterator>::value_type, symbol>

  inline std::generator<GDBusInterfaceInfo*> dbus_infos (Iterator begin, Iterator end)
    {

      std::ranges::subrange range (begin, end);
    return dbus_infos (std::move (range));
    }

  template<std::ranges::input_range Range>
    requires std::same_as<std::ranges::range_value_t<Range>, symbol>

  inline std::generator<GDBusInterfaceInfo*> dbus_infos (Range&& range)
    {

      for (const auto [ name, va, size ]: range)
        {

          if (size != sizeof (GDBusInterfaceInfo))
            continue;

          co_yield read_non_trivial_object<GDBusInterfaceInfo> (va);
        }
    }

  template<typename T>
  inline T** read_non_trivial_array (uint64_t va) const
    {

      auto [ ar, size ] = read_trivial_array_with_sentinel<T*> (va, nullptr);

      for (decltype (size) i = 0; i < size; ++i)
        ar [i] = read_non_trivial_object<T> ((uint64_t) ar [i]);
    return ar;
    }

  template<typename T>
  T* read_non_trivial_object (uint64_t va) const;

  template<> GDBusAnnotationInfo* read_non_trivial_object<GDBusAnnotationInfo> (guint64 va) const;
  template<> GDBusArgInfo* read_non_trivial_object<GDBusArgInfo> (guint64 va) const;
  template<> GDBusInterfaceInfo* read_non_trivial_object<GDBusInterfaceInfo> (guint64 va) const;
  template<> GDBusMethodInfo* read_non_trivial_object<GDBusMethodInfo> (guint64 va) const;
  template<> GDBusPropertyInfo* read_non_trivial_object<GDBusPropertyInfo> (guint64 va) const;
  template<> GDBusSignalInfo* read_non_trivial_object<GDBusSignalInfo> (guint64 va) const;
};