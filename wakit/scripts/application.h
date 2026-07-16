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
#include <wakit/common/boxing.h>

#define G_ERROR_INIT ((GError*) nullptr)

namespace common
{

  class application;
}

class common::application: public boxing::destructible_box<GOptionContext, g_option_context_free>
{
public:

  application (const gchar* parameter_string = nullptr) noexcept;

  int run (int argc, char** argv) noexcept;
  virtual int open (int n_files, char** files, GError** error) noexcept = 0;
};
