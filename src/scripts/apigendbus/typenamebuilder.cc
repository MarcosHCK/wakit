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
#include <glib.h>
#include <ranges>
#include <regex>
#include <scripts/apigendbus/typenamebuilder.h>

template<std::ranges::view Range>
  requires std::same_as<std::ranges::range_value_t<Range>, char>
static inline auto camel_case_ar (Range&& value);
static inline std::string camel_case_pc (std::string_view view);

std::regex _camel_case_token = std::regex ("[\\.-]", std::regex::optimize);

template<std::ranges::view Range>
  requires std::same_as<std::ranges::range_value_t<Range>, char>
[[gnu::always_inline]]
static inline auto camel_case_ar (Range&& value)
{

  std::cregex_token_iterator end, it (value.begin (), value.end (), _camel_case_token, -1);
  std::ranges::subrange sub (it, end);

  return sub | std::views::transform ([] (decltype (*it) sub_match) { return std::string_view (&*sub_match.first, sub_match.length ()); })
             | std::views::filter ([] (std::string_view view) -> bool { return 0 < view.length (); })
             | std::views::transform ([] (std::string_view view) -> std::string { return camel_case_pc (view); });
}

[[gnu::always_inline]]
static inline std::string camel_case_pc (std::string_view view)
{

  auto c = g_utf8_get_char (view.begin ());
  auto n = g_utf8_next_char (view.begin ());

  std::string str;
  gchar unibuf [8 /* g_unichar_to_utf8 needs at least 6 bytes */];

  str.reserve (1 + view.length ());

  str.append (std::string_view (unibuf, g_unichar_to_utf8 (g_unichar_toupper (c), unibuf)));
  str.append (n, view.end ());
return str;
}

std::string typename_builder::build (std::string_view name)
{

  if (name.starts_with (_server_prefix))
    name = name.substr (_server_prefix.length ());

  std::string str;
  str.reserve (name.length () + _client_prefix.length ());
  str.append (_client_prefix);

  for (const auto piece: camel_case_ar (std::string_view (name)))
    str.append (piece);

return str;
}

typename_builder typename_builder::create (std::string_view name, std::string_view type_name)
{

  auto client_prefix = camel_case_ar (std::string_view (name)) | std::views::join | std::ranges::to<std::string> ();
  auto server_prefix = std::string (type_name);

return typename_builder (std::move (client_prefix), std::move (server_prefix));
}