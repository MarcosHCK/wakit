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
#include <algorithm>
#include <fstream>
#include <gio/gio.h>
#include <iostream>
#include <peglib.h>
#include <wakit/scripts/application.h>

using attribute_head = std::string_view;
using attribute_key = std::string_view;
using attribute_value = std::string_view;
struct attribute_arg { attribute_key key; attribute_value value; };
using attribute_args = std::vector<attribute_arg>;
struct attribute { attribute_args args; attribute_head head; };

class application: public common::application
{

  std::string replacement;
public:

  int open (int n_files, char** files, GError** error) noexcept override;
  inline std::ostream& patch_arg (const attribute_arg& arg, std::ostream& stream) noexcept;
  inline std::ostream& patch_attr (const attribute& attr, std::ostream& stream) noexcept;
};

extern "C" GResource* wakit_script_fixvapis__get_resource ();

int main (int argc, char* argv[])
{

  auto app = application ();

  g_log_writer_default_set_use_stderr (true);

  if (G_UNLIKELY (NULL == wakit_script_fixvapis__get_resource ()))
    g_error ("WTF?");

return app.run (argc, argv);
}

[[gnu::always_inline]]
static inline void fill_parser (peg::parser& parser) noexcept
{

  parser ["attribute"] = [](const peg::SemanticValues& vs) -> attribute
    {

      auto head = std::any_cast<std::string_view> (vs [0]);
      auto args = 1 == vs.size () ? attribute_args { } : std::move (*std::any_cast<attribute_args> (&vs [1]));
    return attribute { .args = std::move (args), .head = head };
    };

  parser ["attribute_arg"] = [](const peg::SemanticValues& vs) -> attribute_arg
    {

      auto key = std::any_cast<std::string_view> (vs [0]);
      auto value = std::any_cast<std::string_view> (vs [1]);
    return attribute_arg { .key = key, .value = value };
    };

  parser ["attribute_arg_key"] = [](const peg::SemanticValues& vs) -> std::string_view
    { return vs.token (); };

  parser ["attribute_arg_value"] = [](const peg::SemanticValues& vs) -> std::string_view
    { return vs.token (); };

  parser ["attribute_args"] = [](const peg::SemanticValues& vs) -> attribute_args
    {

      std::vector<attribute_arg> vec { };

      for (const auto& item: vs)
        {
          auto arg = std::move (*std::any_cast<attribute_arg> (&item));
          vec.push_back (std::move (arg));
        }

      std::sort (vec.begin (), vec.end (), [](const attribute_arg& a, const attribute_arg& b)
        { return a.key < b.key; });

    return vec;
    };

  parser ["attribute_head"] = [](const peg::SemanticValues& vs) -> std::string_view
    { return vs.token (); };

  parser ["attribute_list"] = [](const peg::SemanticValues& vs) -> std::vector<attribute>
    {

      std::vector<attribute> vec { };

      for (const auto& item: vs)
        {
          auto attr = std::move (*std::any_cast<attribute> (&item));
          vec.push_back (std::move (attr));
        }
    return vec;
    };
}

[[gnu::always_inline]]
static inline void load_parser (peg::parser& parser, const gchar* path, GError** error = NULL) noexcept
{

  boxing::bytes bytes = NULL;
  GError* tmperr = NULL;

  if (bytes = g_resources_lookup_data (path, G_RESOURCE_LOOKUP_FLAGS_NONE, &tmperr); G_UNLIKELY (nullptr != tmperr))
    return g_propagate_error (error, tmperr);

  gsize size;
  gchar* data = (gchar*) g_bytes_get_data (*bytes, &size);

  if (! parser.load_grammar (std::string_view (data, size)))
    return g_set_error_literal (error, G_IO_ERROR, G_IO_ERROR_INVALID_ARGUMENT, "invalid grammar");

return fill_parser (parser);
}

[[gnu::always_inline]]
static inline std::ostream& print_arg (const attribute_arg& arg, std::ostream& stream) noexcept
{

return stream << arg.key << " = " << arg.value;
}

[[gnu::always_inline]]
static inline std::ostream& print_args (const attribute_args& args, std::ostream& stream) noexcept
{

  stream << "(";

  for (bool first = true; const auto& item: args)
    print_arg (item, !first ? stream << ", " : (first = false, stream));

return stream << ")";
}

[[gnu::always_inline]]
static inline std::ostream& print_attr (const attribute& attr, std::ostream& stream) noexcept
{

  stream << attr.head;

  if (auto& args = attr.args; 0 == args.size ())

    return stream;
  else
    return print_args (attr.args, stream << " ");
}

[[gnu::always_inline]]
inline std::ostream& application::patch_arg (const attribute_arg& arg, std::ostream& stream) noexcept
{

  if (auto value = arg.value; value.contains (',') || value.contains ('/'))

    return print_arg (arg, stream);
  else
    return stream << arg.key << " = " << replacement;
}

[[gnu::always_inline]]
static inline bool is_string (std::string_view view) noexcept
{

  auto size = view.size ();
return size > 0 && '"' == view [0] && '"' == view [size - 1];
}

[[gnu::always_inline]]
inline std::ostream& application::patch_attr (const attribute& attr, std::ostream& stream) noexcept
{

  if ("CCode" != attr.head)
    return print_attr (attr, stream);

  auto& args = attr.args;

  auto iter = std::lower_bound (args.begin (), args.end (), "cheader_filename", [](const attribute_arg& a, const gchar* b)
    { return b > a.key; });

  if (iter == args.end () || "cheader_filename" != iter->key || !is_string (iter->value))
    return print_attr (attr, stream);

  stream << attr.head << ' ';

  for (bool first = (stream << '(', true); const auto& item: attr.args)
    {

      if (&item == &*iter)

        patch_arg (item, !first ? stream << ", " : (first = false, stream));
      else
        print_arg (item, !first ? stream << ", " : (first = false, stream));
    }
return stream << ')';
}

int application::open (int n_files, char** files, GError** error) noexcept
{

  peg::parser parser;
  GError* tmperr = NULL;

  parser.enable_packrat_parsing ();

  parser.set_logger ([](size_t line, size_t col, const std::string& msg, const std::string& rule)
    {
      g_critical ("(%.*s) %" G_GSIZE_FORMAT ": %" G_GSIZE_FORMAT": %.*s",
        (int) rule.length (), rule.c_str (), line, col, (int) msg.length (), msg.c_str ());
    });

  if (load_parser (parser, "/org/hck/wakit/fixvapis.peg", &tmperr); G_LIKELY (nullptr != tmperr))
    return (g_propagate_error (error, tmperr), 1);

  const char* ifile = n_files < 2 ? "-" : files [1];
  const char* ofile = n_files < 3 ? "-" : files [2];

  using istream_t = boxing::destructible_box<std::istream, [](std::istream* stream) noexcept
    { if (stream != &std::cin) delete stream; }>;

  istream_t istream = g_str_equal ("-", ifile) ? &std::cin : new std::ifstream (ifile);

  using ostream_t = boxing::destructible_box<std::ostream, [](std::ostream* stream) noexcept
    { if (stream != &std::cout) delete stream; }>;

  ostream_t ostream = g_str_equal ("-", ofile) ? &std::cout : new std::ofstream (ofile);

  for (std::string line; (bool) std::getline (**istream, line);)
    {

      if (line.starts_with ("$"))
        {
          replacement = line.substr (1);
          continue;
        }

      if (std::vector<attribute> attrs; ! parser.parse (line, attrs))
        (**ostream) << line;

      else for (bool first = true; const auto& item: attrs)
        patch_attr (item, !first ? **ostream << ", " : (first = false, **ostream));

      (**ostream) << std::endl;
    }
return 0;
}