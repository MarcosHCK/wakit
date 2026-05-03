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
#include <inja/inja.hpp>
#include <ranges>
#include <scripts/apigendbus/dbusinfo.h>
#include <scripts/apigendbus/dbusinfogenerator.h>
#include <stdexcept>

class impl
{

  inja::Environment _environment;
  inja::Template _template;

  static inja::Environment _make_environment ()
    {

      inja::Environment env;

      env.add_callback ("object_get_s", _callback_object_get_s);
      env.add_callback ("typename_typename_from_in_args", 1, _callback_typename_from_in_args);
      env.add_callback ("typename_from_interface_info", 1, _callback_typename_from_interface_info);
      env.add_callback ("typename_typename_from_out_args", 1, _callback_typename_from_out_args);

      env.set_lstrip_blocks (true);
      env.set_trim_blocks (true);
    return env;
    }

  static nlohmann::json _callback_object_get_s (std::vector<const nlohmann::json*>& args);
  static nlohmann::json _callback_typename_from_in_args (std::vector<const nlohmann::json*>& args);
  static nlohmann::json _callback_typename_from_interface_info (std::vector<const nlohmann::json*>& args);
  static nlohmann::json _callback_typename_from_out_args (std::vector<const nlohmann::json*>& args);

public:

  inline impl (std::string template_): _environment (_make_environment ()),
                                       _template (_environment.parse (template_))
    { }

  inline void render (std::ostream& stream, const nlohmann::json& data);
};

dbus_info_generator::~dbus_info_generator ()
{

  if (nullptr == _p_impl)
    _p_impl = (delete (impl*) _p_impl, nullptr);
}

dbus_info_generator::dbus_info_generator (std::string template_): _p_impl (new impl (std::move (template_)))
{
}

void dbus_info_generator::generate (std::ostream& stream, std::span<dbus_info> _infos)
{

  nlohmann::json data;
  nlohmann::json infos = _infos | std::views::transform ([](const dbus_info& info)
                                    { return *(nlohmann::json*) *info; })
                                | std::ranges::to<std::vector<nlohmann::json>> ();

  data ["has_signals"] = std::ranges::all_of (infos, [](const nlohmann::json& info)
                          { return info ["signals"].is_array () && info ["signals"].size () > 0; });

  data ["infos"] = infos;

return ((impl*) _p_impl)->render (stream, data);
}

nlohmann::json impl::_callback_object_get_s (std::vector<const nlohmann::json*>& args)
{

  assert (args.size () >= 2);
  assert (args.size () <= 3);
  assert (args [0]->is_object ());
  assert (args [1]->is_string ());

  auto& object = *args [0];
  auto field_name = args [1]->get<std::string_view> ();

  if (auto iter = object.find (field_name); iter != object.end ())

    return *iter;
  else

    if (args.size () == 3)

      return *args [2];
    else
      throw std::out_of_range ("missing property '" + std::string (field_name) + "'");
}

nlohmann::json impl::_callback_typename_from_in_args (std::vector<const nlohmann::json*>& args)
{
return "undefined";
}

nlohmann::json impl::_callback_typename_from_interface_info (std::vector<const nlohmann::json*>& args)
{

  assert (args [0]->is_string ());

  auto interface_name = args[0]->get<std::string_view> ();

  if (auto pos = interface_name.find_last_of ('.'); pos == interface_name.npos)

    return *args [0];
  else
    return interface_name.substr (pos + 1);
}

nlohmann::json impl::_callback_typename_from_out_args (std::vector<const nlohmann::json*>& args)
{
return "undefined";
}

inline void impl::render (std::ostream& stream, const nlohmann::json& data)
{

  _environment.render_to (stream, _template, data);
}