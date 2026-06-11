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
#include <string>
#include <type_traits>

class typename_builder
{

  std::string _client_prefix;
  std::string _server_prefix;

  inline typename_builder (std::string client_prefix, std::string server_prefix)
    noexcept (std::is_nothrow_move_constructible_v<std::string>):
    _client_prefix (std::move (client_prefix)),
    _server_prefix (std::move (server_prefix))
  { }

public:

  std::string build (std::string_view name);
  static typename_builder create (std::string_view name, std::string_view type_name);
};