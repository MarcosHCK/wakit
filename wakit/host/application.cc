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
#include <memory>
#include <wakit/common/mixin.h>
#include <wakit/host/application.h>

extern "C" GType wakit_host_configuration_config_get_type (void) G_GNUC_CONST;

#define _define_param_tag(name_,NAME) \
  struct name_##_tag { static inline constexpr const char* name = #NAME; };

_define_param_tag (configuration, configuration)

gpointer wakit_simple_application_parent_class;
#define _parent wakit_simple_application_parent_class

template<typename param_tag>
[[gnu::always_inline]] static inline GParamSpec* get_param_spec ()
{

  static GParamSpec* __static_pspec = nullptr;

  if (g_once_init_enter (&__static_pspec))
    {

      auto klass = (GObjectClass*) wakit_simple_application_parent_class;
      auto pspec = g_object_class_find_property (klass, param_tag::name);

      g_once_init_leave (&__static_pspec, pspec);
    }
return __static_pspec;
}

template<typename param_tag>
[[gnu::always_inline]] static inline bool has_param (guint n_params, GObjectConstructParam* params)
{

  for (guint i = 0; i < n_params; ++i)
  
    if (g_str_equal (param_tag::name, params [i].pspec->name))
      return true;

return false;
}

static GObject* wakit_host_application_class_constructor (GType g_type, guint n_params, GObjectConstructParam* params)
{

  using param_tag = configuration_tag;

  if (has_param<param_tag> (n_params, params))
    return G_OBJECT_CLASS (_parent)->constructor (g_type, n_params, params);

  auto _params_mixin = _mixin<GObjectConstructParam, 16> (1 + n_params);
  auto _param_value = GValue G_VALUE_INIT;
  auto _param_zero = &_params_mixin.actual () [0];

  std::uninitialized_copy_n (params, n_params, &_params_mixin.actual () [1]);

  _param_zero->pspec = get_param_spec<param_tag> ();
  _param_zero->value = &_param_value;

  GType g_type2 = wakit_host_configuration_config_get_type ();

  g_value_init (&_param_value, g_type2);
  g_value_take_object (&_param_value, g_object_new (g_type2, NULL));

  GObject* result = G_OBJECT_CLASS (_parent)->constructor (g_type, 1 + n_params, _params_mixin.actual ());

return (g_value_unset (&_param_value), result);
}

void wakit_host_application_class_extend (WakitHostApplicationClass* klass)
{

  wakit_simple_application_parent_class = g_type_class_peek_parent ((gpointer) klass);

  G_OBJECT_CLASS (klass)->constructor = wakit_host_application_class_constructor;
}