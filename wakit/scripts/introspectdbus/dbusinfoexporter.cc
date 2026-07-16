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
#include <nlohmann/json.hpp>
#include <wakit/scripts/introspectdbus/dbusinfoexporter.h>

dbus_info_exporter::dbus_info_exporter () noexcept
{
}

template<typename T>
static nlohmann::json _export_object (T object);

template<typename T> static nlohmann::json _export_array (T** objects)
{

  auto o = nlohmann::json::array ();

  for (size_t i = 0; NULL != objects [i]; ++i)
    o.push_back (_export_object (objects [i]));

return o;
}

template<> nlohmann::json _export_object<char*> (char* object)
{

return object;
}

template<> nlohmann::json _export_object<GDBusArgInfo*> (GDBusArgInfo* object)
{

  auto o = nlohmann::json::object ();

  if (auto ptr = object->annotations; nullptr != ptr)
    o ["annotations"] = _export_array (ptr);

  if (auto ptr = object->name; nullptr != ptr)
    o ["name"] = _export_object (ptr);

  if (auto ptr = object->signature; nullptr != ptr)
    o ["signature"] = _export_object (object->signature);

return o;
}

template<> nlohmann::json _export_object<GDBusAnnotationInfo*> (GDBusAnnotationInfo* object)
{

  auto o = nlohmann::json::object ();

  if (auto ptr = object->annotations; nullptr != ptr)
    o ["annotations"] = _export_array (ptr);

  if (auto ptr = object->key; nullptr != ptr)
    o ["key"] = _export_object (ptr);

  if (auto ptr = object->value; nullptr != ptr)
    o ["value"] = _export_object (ptr);

return o;
}

template<> nlohmann::json _export_object<GDBusMethodInfo*> (GDBusMethodInfo* object)
{

  auto o = nlohmann::json::object ();

  if (auto ptr = object->annotations; nullptr != ptr)
    o ["annotations"] = _export_array (ptr);

  if (auto ptr = object->in_args; nullptr != ptr)
    o ["in_args"] = _export_array (ptr);

  if (auto ptr = object->name; nullptr != ptr)
    o ["name"] = _export_object (ptr);

  if (auto ptr = object->out_args; nullptr != ptr)
    o ["out_args"] = _export_array (ptr);

return o;
}

template<> nlohmann::json _export_object<GDBusInterfaceInfo*> (GDBusInterfaceInfo* object)
{

  auto o = nlohmann::json::object ();

  if (auto ptr = object->annotations; nullptr != ptr)
    o ["annotations"] = _export_array (ptr);

  if (auto ptr = object->methods; nullptr != ptr)
    o ["methods"] = _export_array (ptr);

  if (auto ptr = object->name; nullptr != ptr)
    o ["name"] = _export_object (ptr);

  if (auto ptr = object->properties; nullptr != ptr)
    o ["properties"] = _export_array (ptr);

  if (auto ptr = object->signals; nullptr != ptr)
    o ["signals"] = _export_array (ptr);

return o;
}

template<> nlohmann::json _export_object<GDBusPropertyInfoFlags> (GDBusPropertyInfoFlags object)
{

return (int) object;
}

template<> nlohmann::json _export_object<GDBusPropertyInfo*> (GDBusPropertyInfo* object)
{

  auto o = nlohmann::json::object ();

  if (auto ptr = object->annotations; nullptr != ptr)
    o ["annotations"] = _export_array (ptr);

  o ["flags"] = _export_object (object->flags);

  if (auto ptr = object->name; nullptr != ptr)
    o ["name"] = _export_object (ptr);

  if (auto ptr = object->signature; nullptr != ptr)
    o ["signature"] = _export_object (ptr);

return o;
}

template<> nlohmann::json _export_object<GDBusSignalInfo*> (GDBusSignalInfo* object)
{

  auto o = nlohmann::json::object ();

  if (auto ptr = object->annotations; nullptr != ptr)
    o ["annotations"] = _export_array (ptr);

  if (auto ptr = object->args; nullptr != ptr)
    o ["args"] = _export_array (ptr);

  if (auto ptr = object->name; nullptr != ptr)
    o ["name"] = _export_object (ptr);

return o;
}

void dbus_info_exporter::export_ (std::ostream& ostream, GDBusInterfaceInfo* info)
{

  auto json = _export_object (info);
  ostream << json;
}