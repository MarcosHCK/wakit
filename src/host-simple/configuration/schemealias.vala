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

  [Compact (opaque = false),
   CCode (cheader_filename = "host-simple/configuration/schemealias.h")]
  public extern class SchemeAbsoluteAlias
    {

      public string path;
      public string replacement;

      internal extern void free ();
    }

  [Compact (opaque = false)]
  [CCode (cheader_filename = "host-simple/configuration/schemealias.h",
          ref_function = "wakit_simple_configuration_scheme_alias_ref",
          unref_function = "wakit_simple_configuration_scheme_alias_unref",
          type_id = "WAKIT_SIMPLE_CONFIGURATION_TYPE_SCHEME_ALIAS")]
  public extern class SchemeAlias
    {

      public SchemeAliasType type;
      private extern SchemeAlias (SchemeAliasType type);

      internal extern void free () requires (null != SchemeAbsoluteAlias.free)
                                   requires (null != SchemeRegexAlias.free)
                                   requires (null != SchemeVerbatimAlias.free);
    }

  [CCode (cheader_filename = "host-simple/configuration/schemealias.h")]
  public extern enum SchemeAliasType
    {
      ABSOLUTE,
      INVALID,
      REGEX,
      VERBATIM;
      public extern static GLib.Type get_type ();
    }

  [Compact (opaque = false),
   CCode (cheader_filename = "host-simple/configuration/schemealias.h")]
  public extern class SchemeRegexAlias
    {

      public string pattern;
      public string replacement;

      internal extern void free ();
    }

  [Compact (opaque = false),
   CCode (cheader_filename = "host-simple/configuration/schemealias.h")]
  public extern class SchemeVerbatimAlias
    {

      internal extern void free ();
    }
}