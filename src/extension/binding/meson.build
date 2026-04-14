# Copyright (C) 2025-2026 MarcosHCK
# This file is part of wakit.
#
# wakit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# wakit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#

__extension_binding_src = [ ]

foreach bit: [ ]

  __extension_binding_src += [ '@0@.cc'.format (bit) ]
  __extension_binding_src += [ '@0@.h'.format (bit) ]
endforeach

foreach bit: [ 'attributable', 'binding', 'invocable' ]

  __extension_binding_src += [ '@0@.vala'.format (bit) ]
endforeach

__extension_binding_deps = [ __common_dep,
                             __extension_utility_dep, ]

__extension_binding_lib = static_library ('wakit-extension-binding',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Extension.Binding"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Extension.Binding"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_vala_dep, webkitext_dep, __extension_binding_deps ],
  sources: __extension_binding_src,
  vala_args: [ '--includedir', meson.current_build_dir ().replace (base_dir + '/', '') ])

__extension_binding_dep = declare_dependency (dependencies: [ config_dep, webkitext_dep ],
  link_with: __extension_binding_lib)