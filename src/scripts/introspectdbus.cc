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
#include <scripts/introspectdbus/dbusinfoexplorer.h>
#include <scripts/introspectdbus/dbusinfoexporter.h>
#include <span>

class application: public common::application
{

  const gchar* _output = "-";
public:

  inline application (const gchar* parameter_string = nullptr) noexcept;
  inline int open (int n_files, char* files [], GError** error) noexcept override;
};

int main (int argc, char* argv[])
{

  auto app = application ();

  g_log_writer_default_set_use_stderr (true);

return app.run (argc, argv);
}

inline application::application (const gchar* parameter_string) noexcept:
  common::application (parameter_string)
{

  auto context = **this;

  static GOptionEntry entries [] =
  {

    { "output", 'o', 0, G_OPTION_ARG_FILENAME, &_output, nullptr, nullptr },
    { nullptr, 0, 0, G_OPTION_ARG_NONE, nullptr, nullptr, nullptr },
  };

  g_option_context_add_main_entries (context, entries, "en_US");
}

[[gnu::always_inline]]
static inline std::ostream& process (const gchar* file, std::ostream& stream)
{

  dbus_info_explorer explorer (file);
  dbus_info_exporter exporter;

  for (auto info: explorer.dbus_infos (explorer.suffixed_symbols ("_dbus_interface_info")))
    {

      g_info ("found DBus interface '%s'", info->name);

      exporter.export_ (stream, info);
      g_dbus_interface_info_unref (info);
    }
return stream;
}

int application::open (int n_files, gchar* files[], GError** error) noexcept
{

  using ostream_t = boxing::destructible_box<std::ostream, [](std::ostream* stream) noexcept
    { if (stream != &std::cout) delete stream; }>;

  ostream_t ostream = g_str_equal ("-", _output) ? &std::cout : new std::ofstream (_output);

  try
    { for (const auto& file: std::span<gchar*> (files, n_files))
        process (file, **ostream); }
  catch (const std::exception& e)
    { return (g_set_error_literal (error, G_IO_ERROR, G_IO_ERROR_FAILED, e.what ()), 1); }
return 0;
}