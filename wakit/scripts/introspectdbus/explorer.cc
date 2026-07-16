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
#include <LIEF/LIEF.hpp>
#include <wakit/scripts/introspectdbus/explorer.h>

explorer::~explorer ()
{

  delete (LIEF::Binary*) _p_binary;
}

explorer::explorer (const std::string& filename): _p_binary (LIEF::Parser::parse (filename).release ())
{

  if (nullptr == _p_binary)
    throw std::runtime_error ("unknown executable file format");
}

std::generator<explorer::symbol> explorer::suffixed_symbols (const std::string& suffix)
{

  auto& bin = *(LIEF::Binary*) _p_binary;

  for (const auto& symbol: bin.symbols ())
    {

      if (! symbol.name ().ends_with (suffix))
        continue;

      co_yield { symbol.name (), symbol.value (), symbol.size () };
    }
}

std::span<const uint8_t> explorer::read_va (uint64_t va, size_t n_bytes) const
{

return ((LIEF::Binary*) _p_binary)->get_content_from_virtual_address (va, n_bytes);
}