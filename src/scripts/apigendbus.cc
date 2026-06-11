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
#include <fstream>
#include <gio/gio.h>
#include <iostream>
#include <scripts/application.h>
#include <scripts/apigendbus/dbusinfo.h>
#include <scripts/apigendbus/dbusinfogenerator.h>
#include <scripts/apigendbus/dbusinfoimporter.h>
#include <scripts/apigendbus/typenamebuilder.h>
#include <sstream>
#include <vector>

class application: public common::application
{

  const gchar* _name = "";
  const gchar* _type_name = "";
public:

  inline application (const gchar* parameter_string = nullptr) noexcept;
  inline int process (std::string_view template_, std::istream& istream, std::ostream& ostream);
  inline int open (int n_files, char* files [], GError** error) noexcept override;
};

extern "C" GResource* wakit_script_dbus_apigen__get_resource ();

int main (int argc, char* argv[])
{

  auto app = application ("<input> <output>");

  g_log_writer_default_set_use_stderr (true);

  if (G_UNLIKELY (NULL == wakit_script_dbus_apigen__get_resource ()))
    g_error ("WTF?");

return app.run (argc, argv);
}

inline application::application (const gchar* parameter_string) noexcept:
  common::application (parameter_string)
{

  auto context = **this;

  static GOptionEntry entries [] =
  {

    { "name", 0, 0, G_OPTION_ARG_FILENAME, &_name, nullptr, nullptr },
    { "type-name", 0, 0, G_OPTION_ARG_FILENAME, &_type_name, nullptr, nullptr },
    { nullptr, 0, 0, G_OPTION_ARG_NONE, nullptr, nullptr, nullptr },
  };

  g_option_context_add_main_entries (context, entries, "en_US");
}

[[gnu::always_inline]]
static inline boxing::bytes load_template (const gchar* path, GError** error) noexcept
{

  boxing::bytes bytes = NULL;
  GError* tmperr = NULL;

  if (bytes = g_resources_lookup_data (path, G_RESOURCE_LOOKUP_FLAGS_NONE, &tmperr); G_LIKELY (nullptr == tmperr))

    return bytes;
  else
    return (g_propagate_error (error, tmperr), nullptr);
}

[[gnu::always_inline]]
inline int application::process (std::string_view template_, std::istream& istream, std::ostream& ostream)
{

  dbus_info info;
  std::vector<dbus_info> infos;
  dbus_info_importer importer;

  for (std::string line; (bool) std::getline (istream, line);)
    {

      std::stringstream stream (line, std::ios_base::in);

      infos.push_back (std::move ((importer.import_ (stream, info), info)));
    }
return ((dbus_info_generator (template_, typename_builder::create (_name, _type_name))).generate (ostream, infos), 0);
}

int application::open (int argc, char* argv[], GError** error) noexcept
{

  int result = 0;
  GError* tmperr = NULL;
  boxing::bytes template_ = NULL;

  if (G_UNLIKELY (3 != argc))
    return (g_set_error_literal (error, G_OPTION_ERROR, G_OPTION_ERROR_FAILED, "invalid amount of arguments"), 1);

  if (template_ = load_template ("/org/hck/wakit/types.d.ts.j2", &tmperr); G_UNLIKELY (nullptr != tmperr))
    return (g_propagate_error (error, tmperr), 1);

  using istream_t = boxing::destructible_box<std::istream, [](std::istream* stream) noexcept
    { if (stream != &std::cin) delete stream; }>;

  using ostream_t = boxing::destructible_box<std::ostream, [](std::ostream* stream) noexcept
    { if (stream != &std::cout) delete stream; }>;

  try
    { istream_t istream = g_str_equal ("-", argv [1]) ? &std::cin : new std::ifstream (argv [1]);
      ostream_t ostream = g_str_equal ("-", argv [2]) ? &std::cout : new std::ofstream (argv [2]);

      gsize size;
      gchar* data = (gchar*) g_bytes_get_data (*template_, &size);

      result = process (std::string_view (data, size), **istream, **ostream); }

  catch (const std::exception& exception)
    { return (g_set_error_literal (error, G_IO_ERROR, G_IO_ERROR_FAILED, exception.what ()), 1); }

return ((void) template_, result);
}