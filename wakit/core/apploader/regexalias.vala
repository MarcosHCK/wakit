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

  public sealed class RegexAlias: Alias
    {

      public GLib.Regex pattern { get; construct; }
      public string replacement { get; construct; }
      public bool simple { get; construct; }

      public RegexAlias (GLib.Regex pattern, string replacement)
        {
          Object (pattern: pattern, replacement: replacement, simple: false);
        }

      public RegexAlias.literal (GLib.Regex pattern, string replacement)
        {
          Object (pattern: pattern, replacement: replacement, simple: true);
        }

      public override bool matches (string str, size_t length)
        {

          unowned GLib.RegexMatchFlags match_option1 = GLib.RegexMatchFlags.DEFAULT;
          unowned GLib.RegexMatchFlags match_options = match_option1;
          unowned ssize_t string_len = length > (size_t) ssize_t.MAX ? -1 : (ssize_t) length;
          unowned int start_position = 0;
          GLib.MatchInfo match_info;

          try
            {
              if (! _pattern.match_full (str, string_len, start_position, match_options, out match_info))
                return false;
            }
          catch (GLib.RegexError error)
            {

              unowned string code = Enum.to_string ((GLib.RegexError) error.code, typeof (GLib.RegexError));
              unowned string domain = error.domain.to_string ();
              unowned string message = error.message.to_string ();

              warning ("Wakit.Bundle.RegexAlias.matches ()!: %s: %s: %s", domain, code, message);
              return false;
            }
        return match_info.matches ();
        }

      public override string replace (string str, size_t length)
        {

          unowned GLib.RegexMatchFlags match_option1 = GLib.RegexMatchFlags.DEFAULT;
          unowned GLib.RegexMatchFlags match_options = match_option1;
          unowned string replacement = _replacement;
          unowned ssize_t string_len = length > (size_t) ssize_t.MAX ? -1 : (ssize_t) length;
          unowned int start_position = 0;

          try
            {

              if (! _simple)

                return _pattern.replace (str, string_len, start_position, replacement, match_options);
              else
                return _pattern.replace_literal (str, string_len, start_position, replacement, match_options);
            }
          catch (GLib.RegexError error)
            {

              unowned string code = Enum.to_string ((GLib.RegexError) error.code, typeof (GLib.RegexError));
              unowned string domain = error.domain.to_string ();
              unowned string message = error.message.to_string ();

              warning ("Wakit.Bundle.RegexAlias.matches ()!: %s: %s: %s", domain, code, message);
            }
        return str;
        }
    }
}