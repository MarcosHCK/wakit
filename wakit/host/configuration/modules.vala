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

namespace Wakit.Host.Configuration
{

  public sealed class Modules: GLib.Object
    {

      public string? base_dir { get; construct; }
      public ModuleArray items { get; construct; }
      public uint launch_timeout { get; construct; default = 600; }
      public uint shutdown_timeout { get; construct; default = 500; }

      public override void constructed ()
        {

          base.constructed ();
          _base_dir = _base_dir ?? ".";
          _items = _items ?? new ModuleArray ();
        }
    }
}