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
#include <config.h>
#include <host-simple/configuration/schemealias.h>
#include <json-glib/json-glib.h>

static gpointer deserialize (JsonNode* node) noexcept;

G_DEFINE_BOXED_TYPE_WITH_CODE (WakitSimpleConfigurationSchemeAlias,
  wakit_simple_configuration_scheme_alias,
  wakit_simple_configuration_scheme_alias_ref,
  wakit_simple_configuration_scheme_alias_unref,
  json_boxed_register_deserialize_func (g_define_type_id, JSON_NODE_OBJECT, deserialize))

[[gnu::always_inline]]
static inline bool json_object_has_string_member (JsonObject* object, const gchar* name) noexcept
{

  JsonNode* node;

return NULL != (node = json_object_get_member (object, name)) &&
       NULL != json_node_get_string (node);
}

static gpointer deserialize (JsonNode* node) noexcept
{

  auto alias = (WakitSimpleConfigurationSchemeAlias*) NULL;
  auto object = json_node_get_object (node);

  if (json_object_has_string_member (object, "path") && json_object_has_string_member (object, "replacement"))
    {

      constexpr auto type = WAKIT_SIMPLE_CONFIGURATION_SCHEME_ALIAS_TYPE_ABSOLUTE;
      alias = wakit_simple_configuration_scheme_alias_new (type);

      ((WakitSimpleConfigurationSchemeAbsoluteAlias*) alias)->path = g_strdup (json_object_get_string_member (object, "path"));
      ((WakitSimpleConfigurationSchemeAbsoluteAlias*) alias)->replacement = g_strdup (json_object_get_string_member (object, "replacement"));
    }
  else if (json_object_has_string_member (object, "pattern") && json_object_has_string_member (object, "replacement"))
    {

      constexpr auto type = WAKIT_SIMPLE_CONFIGURATION_SCHEME_ALIAS_TYPE_REGEX;
      alias = wakit_simple_configuration_scheme_alias_new (type);

      ((WakitSimpleConfigurationSchemeRegexAlias*) alias)->pattern = g_strdup (json_object_get_string_member (object, "pattern"));
      ((WakitSimpleConfigurationSchemeRegexAlias*) alias)->replacement = g_strdup (json_object_get_string_member (object, "replacement"));
    }
  else if (json_object_has_member (object, "verbatim") && json_object_get_boolean_member (object, "verbatim"))
    {

      constexpr auto type = WAKIT_SIMPLE_CONFIGURATION_SCHEME_ALIAS_TYPE_VERBATIM;
      alias = wakit_simple_configuration_scheme_alias_new (type);
    }
  else
    {
      constexpr auto type = WAKIT_SIMPLE_CONFIGURATION_SCHEME_ALIAS_TYPE_INVALID;
      alias = wakit_simple_configuration_scheme_alias_new (type);
    }
return alias;
}

WakitSimpleConfigurationSchemeAlias* wakit_simple_configuration_scheme_alias_new (WakitSimpleConfigurationSchemeAliasType type)
{

  guint size = 0; switch (type)
    { case WAKIT_SIMPLE_CONFIGURATION_SCHEME_ALIAS_TYPE_ABSOLUTE: size = sizeof (WakitSimpleConfigurationSchemeAbsoluteAlias); break;
      case WAKIT_SIMPLE_CONFIGURATION_SCHEME_ALIAS_TYPE_INVALID: size = sizeof (WakitSimpleConfigurationSchemeAlias); break;
      case WAKIT_SIMPLE_CONFIGURATION_SCHEME_ALIAS_TYPE_REGEX: size = sizeof (WakitSimpleConfigurationSchemeRegexAlias); break;
      case WAKIT_SIMPLE_CONFIGURATION_SCHEME_ALIAS_TYPE_VERBATIM: size = sizeof (WakitSimpleConfigurationSchemeVerbatimAlias); break;
      default: g_assert_not_reached (); }

  auto self = (WakitSimpleConfigurationSchemeAlias*) g_rc_box_alloc (size);

return (self->type = type, self);
}

WakitSimpleConfigurationSchemeAlias* wakit_simple_configuration_scheme_alias_ref (WakitSimpleConfigurationSchemeAlias* alias)
{

  g_return_val_if_fail (NULL != alias, NULL);
return g_rc_box_acquire (alias);
}

static void _destroy (WakitSimpleConfigurationSchemeAlias* alias)
{

  switch (alias->type)
    { case WAKIT_SIMPLE_CONFIGURATION_SCHEME_ALIAS_TYPE_ABSOLUTE: { auto alias_ = (WakitSimpleConfigurationSchemeAbsoluteAlias*) alias;
                                                                    g_free (alias_->path); g_free (alias_->replacement); break; }
      case WAKIT_SIMPLE_CONFIGURATION_SCHEME_ALIAS_TYPE_INVALID: break;
      case WAKIT_SIMPLE_CONFIGURATION_SCHEME_ALIAS_TYPE_REGEX: { auto alias_ = (WakitSimpleConfigurationSchemeRegexAlias*) alias;
                                                                 g_free (alias_->pattern); g_free (alias_->replacement); break; }
      case WAKIT_SIMPLE_CONFIGURATION_SCHEME_ALIAS_TYPE_VERBATIM: break; }
}

void wakit_simple_configuration_scheme_alias_unref (WakitSimpleConfigurationSchemeAlias* alias)
{

  g_return_if_fail (NULL != alias);
return g_rc_box_release_full (alias, (GDestroyNotify) _destroy);
}