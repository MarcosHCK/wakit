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
  WAKIT_HOST_CONFIGURATION_SCHEME_ALIAS_TYPE_ABSOLUTE,
  WAKIT_HOST_CONFIGURATION_SCHEME_ALIAS_TYPE_INVALID,
  WAKIT_HOST_CONFIGURATION_SCHEME_ALIAS_TYPE_REGEX,
  WAKIT_HOST_CONFIGURATION_SCHEME_ALIAS_TYPE_VERBATIM,
} WakitHostConfigurationSchemeAliasType;

#define WAKIT_HOST_CONFIGURATION_TYPE_SCHEME_ALIAS (wakit_host_configuration_scheme_alias_get_type ())

typedef struct _WakitHostConfigurationSchemeAbsoluteAlias WakitHostConfigurationSchemeAbsoluteAlias;
typedef struct _WakitHostConfigurationSchemeAlias WakitHostConfigurationSchemeAlias;
typedef struct _WakitHostConfigurationSchemeRegexAlias WakitHostConfigurationSchemeRegexAlias;
typedef struct _WakitHostConfigurationSchemeVerbatimAlias WakitHostConfigurationSchemeVerbatimAlias;

G_BEGIN_DECLS

  struct _WakitHostConfigurationSchemeAlias
    {

      WakitHostConfigurationSchemeAliasType type;
    };

  struct _WakitHostConfigurationSchemeAbsoluteAlias
    {

      WakitHostConfigurationSchemeAlias parent;
      gchar* path;
      gchar* replacement;
    };

  struct _WakitHostConfigurationSchemeRegexAlias
    {

      WakitHostConfigurationSchemeAlias parent;
      gchar* pattern;
      gchar* replacement;
    };

  struct _WakitHostConfigurationSchemeVerbatimAlias
    {

      WakitHostConfigurationSchemeAlias parent;
    };

  GType wakit_host_configuration_scheme_alias_get_type (void) G_GNUC_CONST;

  WakitHostConfigurationSchemeAlias* wakit_host_configuration_scheme_alias_new (WakitHostConfigurationSchemeAliasType type);
  WakitHostConfigurationSchemeAlias* wakit_host_configuration_scheme_alias_ref (WakitHostConfigurationSchemeAlias* alias);
  void wakit_host_configuration_scheme_alias_unref (WakitHostConfigurationSchemeAlias* alias);

G_END_DECLS