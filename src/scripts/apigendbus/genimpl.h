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
#include <gio/gio.h>
#include <inja/inja.hpp>
#include <stdexcept>

class impl
{

  inja::Environment _environment;
  inja::Template _template;

  static nlohmann::json _callback_has_flag (std::vector<const nlohmann::json*>& args);
  static nlohmann::json _callback_substr (std::vector<const nlohmann::json*>& args);
  static nlohmann::json _callback_typename_from_in_args (std::vector<const nlohmann::json*>& args);
  static nlohmann::json _callback_typename_from_interface_info (std::vector<const nlohmann::json*>& args);
  static nlohmann::json _callback_typename_from_out_args (std::vector<const nlohmann::json*>& args);
  static nlohmann::json _callback_typename_from_signature (std::vector<const nlohmann::json*>& args);

  static inja::Environment _make_environment ();

public:

  inline impl (std::string_view template_): _environment (_make_environment ()),
                                            _template (_environment.parse (template_))
    { }

  inline void render (std::ostream& stream, const nlohmann::json& data);
};

template<std::ranges::input_range Range>
  requires std::same_as<std::ranges::range_value_t<Range>, char>
        && std::contiguous_iterator<std::ranges::iterator_t<Range>>

static inline const GVariantType* _parse_signature (Range&& range)
{

  const char* last;

  if (g_variant_type_string_scan (range.begin (), range.end (), &last) && last == range.end ())

    return (const GVariantType*) range.begin ();
  else
    throw std::runtime_error ("invalid signature '" + std::string (range.begin (), range.end ()) + "'");
}