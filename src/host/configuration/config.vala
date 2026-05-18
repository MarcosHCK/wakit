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
using Wakit.JsonTypes;

namespace Wakit.Host.Configuration
{

  public class Config: BrowserConfig
    {

      public bool decorated { get; construct; default = false; }
      public string? default_route { get; construct; default = null; }
      public string? extensions_dir { get; construct; default = null; }
      public Modules modules { get; construct; }
      public SchemeArray schemes { get; construct; }
      public StringArray secure_schemes { get; construct; }

      public override void constructed ()
        {

          base.constructed ();
          _modules = _modules ?? new Modules ();
          _schemes = _schemes ?? new SchemeArray ();
          _secure_schemes = _secure_schemes ?? new StringArray ();
        }
    }
}