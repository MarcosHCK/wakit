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
#include <common/boxing.h>
#include <fstream>
#include <gio/gio.h>
#include <iostream>
#include <scripts/introspectdbus.h>
#include <scripts/introspectdbus/dbusinfoexplorer.h>
#include <scripts/introspectdbus/dbusinfoexporter.h>

#define G_ERROR_INIT ((GError*) nullptr)

using _box_GOptionContext = boxing::destructible_box<GOptionContext, g_option_context_free>;

class Application: public _box_GOptionContext
{

  const gchar* _output = "-";
public:

  inline Application (const gchar* parameter_string = nullptr) noexcept;

  inline bool run (int* argc_, char*** argv_, GError** error) noexcept;

  inline void process (std::ostream& out, int n_filename, const char* filenames []);
  inline void process (std::ostream& out, const char* filename);
};

int main (int argc, char* argv[])
{

  auto app = Application ();
  auto tmperr = G_ERROR_INIT;

  g_log_writer_default_set_use_stderr (true);

  if (app.run (&argc, &argv, &tmperr); G_UNLIKELY (nullptr == tmperr))
    return 0;

  const auto code = tmperr->code;
  const auto domain = g_quark_to_string (tmperr->domain);
  const auto message = tmperr->message;

  g_printerr ("g_option_context_parse ()!: %s: %u: %s\n", domain, code, message);

return (g_error_free (tmperr), 0);
}

inline Application::Application (const gchar* parameter_string) noexcept:
  _box_GOptionContext (g_option_context_new (parameter_string))
{

  auto context = **this;

  static GOptionEntry entries [] =
  {

    { "output", 'o', 0, G_OPTION_ARG_FILENAME, &_output, nullptr, nullptr },
    { nullptr, 0, 0, G_OPTION_ARG_NONE, nullptr, nullptr, nullptr },
  }; 

  g_option_context_add_main_entries (context, entries, "en_US");
  g_option_context_set_help_enabled (context, TRUE);
  g_option_context_set_ignore_unknown_options (context, FALSE);
  g_option_context_set_strict_posix (context, FALSE);
  g_option_context_set_translation_domain (context, "en_US");
}

static G_DEFINE_QUARK (introspect-dbus-error-quark, cpp_error)

inline bool Application::run (int* argc_, char*** argv_, GError** error) noexcept
{

  auto context = **this;
  auto tmperr = G_ERROR_INIT;

  if (g_option_context_parse (context, argc_, argv_, error); G_UNLIKELY (nullptr != tmperr))
    return false;

  try
    {

      if (g_str_equal ("-", _output))

        process (std::cout, *argc_, (const gchar**) *argv_);
      else
        { std::ofstream out (_output);
          process (out, *argc_, (const gchar**) *argv_); }
    }
  catch (std::exception& exception)
    { g_set_error_literal (error, cpp_error_quark (), 0, exception.what ()); }

return true;
}

inline void Application::process (std::ostream& out, int n_filename, const char* filenames [])
{

  for (std::remove_cvref_t<decltype (n_filename)> i = 1; i < n_filename; ++i)
    process (out, filenames [i]);
}

inline void Application::process (std::ostream& out, const char* filename)
{

  dbus_info_explorer explorer (filename);
  dbus_info_exporter exporter;

  for (auto info: explorer.dbus_infos (explorer.suffixed_symbols ("_dbus_interface_info")))
    {

      g_info ("found DBus interface '%s'", info->name);

      exporter.export_ (out, info);
      g_dbus_interface_info_unref (info);
    }
}