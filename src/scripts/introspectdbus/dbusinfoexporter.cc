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
#include <exception>
#include <json-glib/json-glib.h>
#include <scripts/introspectdbus/dbusinfoexporter.h>

dbus_info_exporter::~dbus_info_exporter () noexcept
{
  g_object_unref (_p_generator);
}

dbus_info_exporter::dbus_info_exporter () noexcept: _p_generator (json_generator_new ())
{
}

template<typename T>
static void _export_object (JsonBuilder* builder, T object);

template<typename T> static void _export_array (JsonBuilder* builder, T** objects)
{

  json_builder_begin_array (builder);

  for (size_t i = 0; NULL != objects [i]; ++i)
    _export_object (builder, objects [i]);

  json_builder_end_array (builder);
}

template<> void _export_object<char*> (JsonBuilder* builder, char* object)
{

  json_builder_add_string_value (builder, object);
}

template<> void _export_object<GDBusArgInfo*> (JsonBuilder* builder, GDBusArgInfo* object)
{

  json_builder_begin_object (builder);

  if (auto ptr = object->annotations; nullptr != ptr)
    {

      json_builder_set_member_name (builder, "annotation");
      _export_array (builder, object->annotations);
    }

  if (auto ptr = object->name; nullptr != ptr)
    {

      json_builder_set_member_name (builder, "name");
      _export_object (builder, object->name);
    }

  if (auto ptr = object->signature; nullptr != ptr)
    {

      json_builder_set_member_name (builder, "signature");
      _export_object (builder, object->signature);
    }

  json_builder_end_object (builder);
}

template<> void _export_object<GDBusAnnotationInfo*> (JsonBuilder* builder, GDBusAnnotationInfo* object)
{

  json_builder_begin_object (builder);

  if (auto ptr = object->annotations; nullptr != ptr)
    {

      json_builder_set_member_name (builder, "annotation");
      _export_array (builder, object->annotations);
    }

  if (auto ptr = object->key; nullptr != ptr)
    {

      json_builder_set_member_name (builder, "key");
      _export_object (builder, object->key);
    }

  if (auto ptr = object->value; nullptr != ptr)
    {

      json_builder_set_member_name (builder, "value");
      _export_object (builder, object->value);
    }

  json_builder_end_object (builder);
}

template<> void _export_object<GDBusMethodInfo*> (JsonBuilder* builder, GDBusMethodInfo* object)
{

  json_builder_begin_object (builder);

  if (auto ptr = object->annotations; nullptr != ptr)
    {

      json_builder_set_member_name (builder, "annotation");
      _export_array (builder, object->annotations);
    }

  if (auto ptr = object->in_args; nullptr != ptr)
    {

      json_builder_set_member_name (builder, "in_args");
      _export_array (builder, object->in_args);
    }

  if (auto ptr = object->name; nullptr != ptr)
    {

      json_builder_set_member_name (builder, "name");
      _export_object (builder, object->name);
    }

  if (auto ptr = object->out_args; nullptr != ptr)
    {

      json_builder_set_member_name (builder, "out_args");
      _export_array (builder, object->out_args);
    }

  json_builder_end_object (builder);
}

template<> void _export_object<GDBusInterfaceInfo*> (JsonBuilder* builder, GDBusInterfaceInfo* object)
{

  json_builder_begin_object (builder);

  if (auto ptr = object->annotations; nullptr != ptr)
    {

      json_builder_set_member_name (builder, "annotation");
      _export_array (builder, object->annotations);
    }

  if (auto ptr = object->methods; nullptr != ptr)
    {

      json_builder_set_member_name (builder, "methods");
      _export_array (builder, object->methods);
    }

  if (auto ptr = object->name; nullptr != ptr)
    {

      json_builder_set_member_name (builder, "name");
      _export_object (builder, object->name);
    }

  if (auto ptr = object->properties; nullptr != ptr)
    {

      json_builder_set_member_name (builder, "properties");
      _export_array (builder, object->properties);
    }

  if (auto ptr = object->signals; nullptr != ptr)
    {

      json_builder_set_member_name (builder, "signals");
      _export_array (builder, object->signals);
    }

  json_builder_end_object (builder);
}

template<> void _export_object<GDBusPropertyInfoFlags> (JsonBuilder* builder, GDBusPropertyInfoFlags object)
{

  json_builder_add_int_value (builder, (gint64) object);
}

template<> void _export_object<GDBusPropertyInfo*> (JsonBuilder* builder, GDBusPropertyInfo* object)
{

  json_builder_begin_object (builder);

  if (auto ptr = object->annotations; nullptr != ptr)
    {

      json_builder_set_member_name (builder, "annotation");
      _export_array (builder, object->annotations);
    }

  json_builder_set_member_name (builder, "flags");
  _export_object (builder, object->flags);

  if (auto ptr = object->name; nullptr != ptr)
    {

      json_builder_set_member_name (builder, "name");
      _export_object (builder, object->name);
    }

  if (auto ptr = object->signature; nullptr != ptr)
    {

      json_builder_set_member_name (builder, "signature");
      _export_object (builder, object->signature);
    }

  json_builder_end_object (builder);
}

template<> void _export_object<GDBusSignalInfo*> (JsonBuilder* builder, GDBusSignalInfo* object)
{

  json_builder_begin_object (builder);

  if (auto ptr = object->annotations; nullptr != ptr)
    {

      json_builder_set_member_name (builder, "annotation");
      _export_array (builder, object->annotations);
    }

  if (auto ptr = object->args; nullptr != ptr)
    {

      json_builder_set_member_name (builder, "args");
      _export_array (builder, object->args);
    }

  if (auto ptr = object->name; nullptr != ptr)
    {

      json_builder_set_member_name (builder, "name");
      _export_object (builder, object->name);
    }

  json_builder_end_object (builder);
}

struct _OStreamStream { GOutputStream parent; std::ostream* stream; };

G_DECLARE_FINAL_TYPE (OStreamStream, ostream_stream, , OStreamStream, GOutputStream)
G_DEFINE_FINAL_TYPE (OStreamStream, ostream_stream, G_TYPE_OUTPUT_STREAM)

static void ostream_stream_class_set_property (GObject* pself, guint property_id, const GValue* value, GParamSpec* pspec)
{

  switch (auto self = (OStreamStream*) pself; property_id)
    {

    case 1: self->stream = (std::ostream*) g_value_get_pointer (value);
      break;

    default: G_OBJECT_WARN_INVALID_PROPERTY_ID (pself, property_id, pspec);
      break;
    }
}

static gssize ostream_stream_class_write_fn (GOutputStream* pself, const void* buffer, gsize size, GCancellable* cancellable, GError** error)
{

  auto& ostream = *((OStreamStream*) pself)->stream;

  try
    { ostream.exceptions (std::ostream::badbit);
      return (ostream.write ((char*) buffer, size), size); }
  catch (std::exception& exception)
    { return (g_set_error_literal (error, G_IO_ERROR, G_IO_ERROR_FAILED, exception.what ()), -1); }
}

static void ostream_stream_class_init (OStreamStreamClass* klass)
{

  G_OBJECT_CLASS (klass)->set_property = ostream_stream_class_set_property;

  G_OUTPUT_STREAM_CLASS (klass)->write_fn = ostream_stream_class_write_fn;

  g_object_class_install_property (G_OBJECT_CLASS (klass), 1, g_param_spec_pointer ("ostream", "ostream", "ostream",
    (GParamFlags) (G_PARAM_CONSTRUCT_ONLY | G_PARAM_WRITABLE | G_PARAM_STATIC_STRINGS)));
}

static void ostream_stream_init (OStreamStream* self)
{
}

void dbus_info_exporter::export_ (std::ostream& ostream, GDBusInterfaceInfo* info)
{

  auto builder = json_builder_new ();
  auto stream = (GOutputStream*) g_object_new (ostream_stream_get_type (), "ostream", &ostream, NULL);

  _export_object (builder, info);

  json_generator_take_root ((JsonGenerator*) _p_generator, json_builder_get_root (builder));
  g_object_unref (builder);

  GError* tmperr = nullptr;
  json_generator_to_stream ((JsonGenerator*) _p_generator, stream, NULL, &tmperr);

  if (G_UNLIKELY (nullptr != tmperr))
    throw new std::runtime_error (g_quark_to_string (tmperr->domain) + ((":" + std::to_string (tmperr->code)) + ":") + tmperr->message);
}