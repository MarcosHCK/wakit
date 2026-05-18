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

namespace Wakit.Loaders
{

  public sealed class AbsoluteAlias: Alias
    {

      public string pattern { get; construct; }
      public string replacement { get; construct; }
      private size_t _length;

      public AbsoluteAlias (string pattern, string replacement)
        {
          Object (pattern: pattern, replacement: replacement);
        }

      public override void constructed ()
        {

          base.constructed ();
          _length = _pattern.length;
        }

      public override bool matches (string str, size_t length)
        {

          return length == _length && str == _pattern;
        }

      public override string replace (string str, size_t length)
        {

          return replacement;
        }
    }
}