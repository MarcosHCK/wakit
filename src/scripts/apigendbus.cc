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
#include <scripts/apigendbus/dbusinfo.h>
#include <scripts/apigendbus/dbusinfogenerator.h>
#include <scripts/apigendbus/dbusinfoimporter.h>
#include <sstream>
#include <vector>

#define G_ERROR_INIT ((GError*) nullptr)
static G_DEFINE_QUARK (introspect-dbus-error-quark, cpp_error)

using _box_GOptionContext = boxing::destructible_box<GOptionContext, g_option_context_free>;

class Application: public _box_GOptionContext
{

  const gchar* template_ = NULL;
public:

  inline Application (const gchar* parameter_string = nullptr) noexcept;

  inline bool run (int* argc_, char*** argv_, GError** error) noexcept;

  inline void print_help ()
    {

      auto str = g_option_context_get_help (*(*this), TRUE, NULL);

      g_printerr ("%s\n", str);
      g_free (str);
    }

  inline void process (const char* out, const char* in);
  inline void process (const char* out, std::istream& in);
  inline void process (std::ostream& out, std::istream& in);
};

int main (int argc, char* argv[])
{

  auto app = Application ("<input> <output>");
  auto tmperr = G_ERROR_INIT;

  g_log_writer_default_set_use_stderr (true);

  if (app.run (&argc, &argv, &tmperr); G_UNLIKELY (nullptr == tmperr))
    return 0;

  const auto code = tmperr->code;
  const auto domain = g_quark_to_string (tmperr->domain);
  const auto message = tmperr->message;

  if (! g_error_matches (tmperr, cpp_error_quark (), 0))
    app.print_help ();

  g_printerr ("g_option_context_parse ()!: %s: %u: %s\n", domain, code, message);

return (g_error_free (tmperr), 1);
}

inline Application::Application (const gchar* parameter_string) noexcept:
  _box_GOptionContext (g_option_context_new (parameter_string))
{

  auto context = **this;

  static GOptionEntry entries [] =
  {

    { "template", 0, 0, G_OPTION_ARG_FILENAME, &template_, nullptr, nullptr },
    { nullptr, 0, 0, G_OPTION_ARG_NONE, nullptr, nullptr, nullptr },
  }; 

  g_option_context_add_main_entries (context, entries, "en_US");
  g_option_context_set_help_enabled (context, TRUE);
  g_option_context_set_ignore_unknown_options (context, FALSE);
  g_option_context_set_strict_posix (context, FALSE);
  g_option_context_set_translation_domain (context, "en_US");
}

inline bool Application::run (int* argc_, char*** argv_, GError** error) noexcept
{

  auto context = **this;
  auto tmperr = G_ERROR_INIT;

  if (g_option_context_parse (context, argc_, argv_, error); G_UNLIKELY (nullptr != tmperr))
    return false;

  if (G_UNLIKELY (3 != *argc_))
    return (g_set_error_literal (error, G_OPTION_ERROR, G_OPTION_ERROR_FAILED, "invalid amount of arguments"), false);

  try
    { process ((*argv_) [2], (*argv_) [1]); }
  catch (std::exception& exception)
    { g_set_error_literal (error, cpp_error_quark (), 0, exception.what ()); }

return true;
}

inline void Application::process (const char* out, const char* in)
{

  if (g_str_equal ("-", in))
    return process (out, std::cin);

  std::ifstream stream (in);

return process (out, stream);
}

inline void Application::process (const char* out, std::istream& in)
{

  if (g_str_equal ("-", out))
    return process (std::cout, in);

  std::ofstream stream (out);

return process (stream, in);
}

static inline std::string load_template (const gchar* template_)
{

  if (g_str_equal ("-", template_))

    return std::string (std::istreambuf_iterator<char> (std::cin),
                        std::istreambuf_iterator<char> ());

  std::ifstream stream (template_);

  return std::string (std::istreambuf_iterator<char> (stream),
                      std::istreambuf_iterator<char> ());
}

inline void Application::process (std::ostream& output, std::istream& input)
{

  dbus_info info;
  std::vector<dbus_info> infos;
  dbus_info_importer importer;

  for (std::string line; std::getline (input, line); )
    {

      std::stringstream stream (line, std::ios_base::in);

      infos.push_back (std::move ((importer.import_ (stream, info), info)));
    }
return (dbus_info_generator (load_template (template_))).generate (output, infos);
}