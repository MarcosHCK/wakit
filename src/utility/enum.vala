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

namespace Wakit.Utility
{

  public errordomain EnumError
    {
      FAILED = 0,
      UNKNOWN_NAME = 1,
      UNKNOWN_NICK = 2,
      UNKNOWN_VALUE = 3;

      public extern static GLib.Quark quark ();
    }

  [CCode (cheader_filename = "utility/enum.h")] namespace Enum
    {

      [CCode (simple_generics = true)]
      public extern static unowned string as_string<T> ([CCode (type = "gint")] T value, GLib.Type g_type = typeof (T)) throws EnumError;

      [CCode (simple_generics = true, type = "gint")]
      public extern static T from_name<T> (string name, GLib.Type g_type = typeof (T)) throws EnumError;

      [CCode (simple_generics = true, type = "gint")]
      public extern static T from_nick<T> (string nick, GLib.Type g_type = typeof (T)) throws EnumError;

      [CCode (simple_generics = true)]
      public extern static unowned string to_string<T> ([CCode (type = "gint")] T value, GLib.Type g_type = typeof (T));
    }
}