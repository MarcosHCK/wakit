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
#pragma once
#include <glib-object.h>

typedef enum
{
  WAKIT_SIMPLE_CONFIGURATION_SCHEME_ALIAS_TYPE_ABSOLUTE,
  WAKIT_SIMPLE_CONFIGURATION_SCHEME_ALIAS_TYPE_INVALID,
  WAKIT_SIMPLE_CONFIGURATION_SCHEME_ALIAS_TYPE_REGEX,
  WAKIT_SIMPLE_CONFIGURATION_SCHEME_ALIAS_TYPE_VERBATIM,
} WakitSimpleConfigurationSchemeAliasType;

#define WAKIT_SIMPLE_CONFIGURATION_TYPE_SCHEME_ALIAS (wakit_simple_configuration_scheme_alias_get_type ())

typedef struct _WakitSimpleConfigurationSchemeAbsoluteAlias WakitSimpleConfigurationSchemeAbsoluteAlias;
typedef struct _WakitSimpleConfigurationSchemeAlias WakitSimpleConfigurationSchemeAlias;
typedef struct _WakitSimpleConfigurationSchemeRegexAlias WakitSimpleConfigurationSchemeRegexAlias;
typedef struct _WakitSimpleConfigurationSchemeVerbatimAlias WakitSimpleConfigurationSchemeVerbatimAlias;

G_BEGIN_DECLS

  struct _WakitSimpleConfigurationSchemeAlias
    {

      WakitSimpleConfigurationSchemeAliasType type;
    };

  struct _WakitSimpleConfigurationSchemeAbsoluteAlias
    {

      WakitSimpleConfigurationSchemeAlias parent;
      gchar* path;
      gchar* replacement;
    };

  struct _WakitSimpleConfigurationSchemeRegexAlias
    {

      WakitSimpleConfigurationSchemeAlias parent;
      gchar* pattern;
      gchar* replacement;
    };

  struct _WakitSimpleConfigurationSchemeVerbatimAlias
    {

      WakitSimpleConfigurationSchemeAlias parent;
    };

  GType wakit_simple_configuration_scheme_alias_get_type (void) G_GNUC_CONST;

  WakitSimpleConfigurationSchemeAlias* wakit_simple_configuration_scheme_alias_new (WakitSimpleConfigurationSchemeAliasType type);
  WakitSimpleConfigurationSchemeAlias* wakit_simple_configuration_scheme_alias_ref (WakitSimpleConfigurationSchemeAlias* alias);
  void wakit_simple_configuration_scheme_alias_unref (WakitSimpleConfigurationSchemeAlias* alias);

G_END_DECLS