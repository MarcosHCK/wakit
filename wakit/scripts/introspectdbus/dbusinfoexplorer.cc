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
#include <config.h>
#include <wakit/scripts/introspectdbus/dbusinfoexplorer.h>

template<> GDBusAnnotationInfo* dbus_info_explorer::read_non_trivial_object<GDBusAnnotationInfo> (guint64 va) const
  {

    auto obj = g_new (GDBusAnnotationInfo, 1);

    read_trivial_object (va, *obj);

    obj->ref_count = 1;

    if (auto ptr = obj->annotations; NULL != ptr)
      obj->annotations = read_non_trivial_array<GDBusAnnotationInfo> ((guint64) ptr);

    if (auto ptr = obj->key; NULL != ptr)
      obj->key = read_string ((guint64) ptr);

    if (auto ptr = obj->value; NULL != ptr)
      obj->value = read_string ((guint64) ptr);

  return obj;
  }

template<> GDBusArgInfo* dbus_info_explorer::read_non_trivial_object<GDBusArgInfo> (guint64 va) const
  {

    auto obj = g_new (GDBusArgInfo, 1);

    read_trivial_object (va, *obj);

    obj->ref_count = 1;

    if (auto ptr = obj->annotations; NULL != ptr)
      obj->annotations = read_non_trivial_array<GDBusAnnotationInfo> ((guint64) ptr);

    if (auto ptr = obj->name; NULL != ptr)
      obj->name = read_string ((guint64) ptr);

    if (auto ptr = obj->signature; NULL != ptr)
      obj->signature = read_string ((guint64) ptr);

  return obj;
  }

template<> GDBusInterfaceInfo* dbus_info_explorer::read_non_trivial_object<GDBusInterfaceInfo> (guint64 va) const
  {

    auto obj = g_new (GDBusInterfaceInfo, 1);

    read_trivial_object (va, *obj);

    obj->ref_count = 1;

    if (auto ptr = obj->annotations; NULL != ptr)
      obj->annotations = read_non_trivial_array<GDBusAnnotationInfo> ((guint64) ptr);

    if (auto ptr = obj->methods; NULL != ptr)
      obj->methods = read_non_trivial_array<GDBusMethodInfo> ((guint64) ptr);

    if (auto ptr = obj->name; NULL != ptr)
      obj->name = read_string ((guint64) ptr);

    if (auto ptr = obj->properties; NULL != ptr)
      obj->properties = read_non_trivial_array<GDBusPropertyInfo> ((guint64) ptr);

    if (auto ptr = obj->signals; NULL != ptr)
      obj->signals = read_non_trivial_array<GDBusSignalInfo> ((guint64) ptr);

  return obj;
  }

template<> GDBusMethodInfo* dbus_info_explorer::read_non_trivial_object<GDBusMethodInfo> (guint64 va) const
  {

    auto obj = g_new (GDBusMethodInfo, 1);

    read_trivial_object (va, *obj);

    obj->ref_count = 1;

    if (auto ptr = obj->annotations; NULL != ptr)
      obj->annotations = read_non_trivial_array<GDBusAnnotationInfo> ((guint64) ptr);

    if (auto ptr = obj->in_args; NULL != ptr)
      obj->in_args = read_non_trivial_array<GDBusArgInfo> ((guint64) ptr);

    if (auto ptr = obj->name; NULL != ptr)
      obj->name = read_string ((guint64) ptr);

    if (auto ptr = obj->out_args; NULL != ptr)
      obj->out_args = read_non_trivial_array<GDBusArgInfo> ((guint64) ptr);

  return obj;
  }

template<> GDBusPropertyInfo* dbus_info_explorer::read_non_trivial_object<GDBusPropertyInfo> (guint64 va) const
  {

    auto obj = g_new (GDBusPropertyInfo, 1);

    read_trivial_object (va, *obj);

    obj->ref_count = 1;

    if (auto ptr = obj->annotations; NULL != ptr)
      obj->annotations = read_non_trivial_array<GDBusAnnotationInfo> ((guint64) ptr);

    if (auto ptr = obj->name; NULL != ptr)
      obj->name = read_string ((guint64) ptr);

    if (auto ptr = obj->signature; NULL != ptr)
      obj->signature = read_string ((guint64) ptr);

  return obj;
  }

template<> GDBusSignalInfo* dbus_info_explorer::read_non_trivial_object<GDBusSignalInfo> (guint64 va) const
  {

    auto obj = g_new (GDBusSignalInfo, 1);

    read_trivial_object (va, *obj);

    obj->ref_count = 1;

    if (auto ptr = obj->annotations; NULL != ptr)
      obj->annotations = read_non_trivial_array<GDBusAnnotationInfo> ((guint64) ptr);

    if (auto ptr = obj->args; NULL != ptr)
      obj->args = read_non_trivial_array<GDBusArgInfo> ((guint64) ptr);

    if (auto ptr = obj->name; NULL != ptr)
      obj->name = read_string ((guint64) ptr);

  return obj;
  }