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

namespace Wakit.Simple.Configuration
{

  public class Config: BrowserConfig
    {

      public bool decorated { get; construct; default = false; }
      public string? default_route { get; construct; default = null; }
      public GenericArray<Scheme> schemes { get; construct; }

      public override void constructed ()
        {

          base.constructed ();
          _schemes = _schemes ?? new GenericArray<Scheme> ();
        }
    }
}