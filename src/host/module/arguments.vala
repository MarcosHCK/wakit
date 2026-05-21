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

namespace Wakit.Host
{

  public sealed class Arguments: GLib.Object
    {

      public string appbus_address { get; construct set; }
      public uint appbus_timeout { get; construct set; default = 1200; }
      public uint launch_timeout { get; construct set; default = 600; }
      public string? module_digest { get; construct set; }
      public string module_filename { get; construct set; }
      public string module_loader { get; construct set; }
    }
}