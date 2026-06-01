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
#include <scripts/apigendbus/dbusinfo.h>
#include <scripts/apigendbus/dbusinfogenerator.h>
#include <scripts/apigendbus/genimpl.h>

dbus_info_generator::~dbus_info_generator ()
{

  if (nullptr == _p_impl)
    _p_impl = (delete (impl*) _p_impl, nullptr);
}

dbus_info_generator::dbus_info_generator (std::string_view template_): _p_impl (new impl (template_))
{
}

static inline bool has_signals (const nlohmann::json& info)
{

  assert (info.is_object ());

  if (auto iter = info.find ("signals"); iter == info.end ())

    return false;
  else
    return iter->is_array () && iter->size () > 0;
}

void dbus_info_generator::generate (std::ostream& stream, std::span<dbus_info> _infos)
{

  nlohmann::json data;
  nlohmann::json infos = _infos | std::views::transform ([](const dbus_info& info)
                                    { return *(nlohmann::json*) *info; })
                                | std::ranges::to<std::vector<nlohmann::json>> ();

  data ["has_signals"] = std::ranges::any_of (infos, has_signals);
  data ["infos"] = infos;

return ((impl*) _p_impl)->render (stream, data);
}

nlohmann::json impl::_callback_has_flag (std::vector<const nlohmann::json*>& args)
{

  assert (args.size () == 2);
  assert (args [0]->is_number_integer ());
  assert (args [1]->is_number_integer ());

return 0 != (args [0]->get<size_t> () & args [1]->get<size_t> ());
}

nlohmann::json impl::_callback_substr (std::vector<const nlohmann::json*>& args)
{

  assert (args.size () > 0 && 4 > args.size ());
  assert (args [0]->is_string ());

  auto str = args [0]->get<std::string_view> ();

  size_t length = str.npos;
  size_t offset = 0;

  if (args.size () > 1) { assert (args [1]->is_number_unsigned ());
                          offset = args [1]->get<size_t> (); }

  if (args.size () > 2) { assert (args [2]->is_number_unsigned ());
                          length = args [2]->get<size_t> (); }

return str.substr (offset, length);
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

inja::Environment impl::_make_environment ()
{

  inja::Environment env;

  env.add_callback ("has_flag", _callback_has_flag);
  env.add_callback ("substr", _callback_substr);
  env.add_callback ("typename_from_in_args", 1, _callback_typename_from_in_args);
  env.add_callback ("typename_from_interface_info", 1, _callback_typename_from_interface_info);
  env.add_callback ("typename_from_out_args", 1, _callback_typename_from_out_args);
  env.add_callback ("typename_from_signature", 1, _callback_typename_from_signature);

# define _define_constant(name) \
  env.add_callback (G_STRINGIFY (name), 0, [](inja::Arguments&) \
    { return name; })

  _define_constant (G_DBUS_PROPERTY_INFO_FLAGS_NONE);
  _define_constant (G_DBUS_PROPERTY_INFO_FLAGS_READABLE);
  _define_constant (G_DBUS_PROPERTY_INFO_FLAGS_WRITABLE);
# undef _define_constant

  env.set_lstrip_blocks (true);
  env.set_trim_blocks (true);
return env;
}

inline void impl::render (std::ostream& stream, const nlohmann::json& data)
{

  _environment.render_to (stream, _template, data);
}