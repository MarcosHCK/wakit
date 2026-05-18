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

  public sealed class Scheme: GLib.Object
    {

      public SchemeAliasArray aliases { get; construct; }
      public string? bundle { get; construct; default = null; }
      public bool local { get; construct; default = true; }
      public string name { get; construct; }
      public bool secure { get; construct; default = false; }
      public string? tree { get; construct; default = null; }

      public override void constructed ()
        {

          base.constructed ();
          _aliases = _aliases ?? new SchemeAliasArray ();
        }
    }
}