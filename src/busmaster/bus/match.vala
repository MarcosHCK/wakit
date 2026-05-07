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

namespace Wakit.Busmaster.Bus
{

  internal sealed class Match
    {

      private bool _eavesdrop = false;
      private MatchElement[] _elements;
      private GLib.DBusMessageType _type = GLib.DBusMessageType.INVALID;

      ~Match ()
        {
          printerr ("~Match ()\n");
        }

      class construct
        {

          if (unlikely (null == (void*) Server.match_name))
            GLib.error ("WTF?");
        }

      private Match (bool eavesdrop, owned MatchElement[] elements, GLib.DBusMessageType type)
        {

          _eavesdrop = eavesdrop;
          _elements = (owned) elements;
          _type = type;
        }

      public static int compare (Match a, Match b)
        {

          return a._eavesdrop == b._eavesdrop && a._type == b._type &&
                 a._elements.length == b._elements.length && equal_impl (a._elements, b._elements)
            ? 0 : 1;
        }

      [CCode (cheader_filename = "busmaster/bus/match.h")]
      extern static bool equal_impl ([CCode (array_length = false)] MatchElement[] a,
                                     [CCode (array_length_pos = 2.9, array_length_type = "guint")] MatchElement[] b);

      public bool matches (GLib.DBusMessage message, bool has_destination, Server server)
        {

          if (has_destination && !_eavesdrop)
            return false;

          if (GLib.DBusMessageType.INVALID != _type && message.get_message_type () != _type)
            return false;

        return matches_impl (message, has_destination, server, _elements);
        }

      [CCode (cheader_filename = "busmaster/bus/match.h")]
      extern static bool matches_impl (GLib.DBusMessage message, bool has_destination,
                                       Server server,
                                       [CCode (array_length_pos = 3.9, array_length_type = "guint")] MatchElement[] elements);

      public static Match? parse (string rule)
        {

          bool eavesdrop;
          GLib.Array<MatchElement> elements;
          GLib.DBusMessageType type;

          if (null == (elements = parse_impl (rule, out eavesdrop, out type)) || 0 == elements.length)

            return null;
          else
            return new Match (eavesdrop, elements.steal (), type);
        }

      [CCode (cheader_filename = "busmaster/bus/match.h")]
      extern static GLib.Array<MatchElement>? parse_impl (string rule, out bool eavesdrop, out GLib.DBusMessageType type);
    }
}