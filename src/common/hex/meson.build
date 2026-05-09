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

gobject_dep = dependency ('gobject-2.0', required: true)

__common_hex_src = [ ]

foreach lib: [ ]

  __common_hex_src += [ '@0@.cc'.format (lib) ]
  __common_hex_src += [ '@0@.h'.format (lib) ]
endforeach

foreach lib: [ 'hex' ]

  __common_hex_src += [ '@0@.vala'.format (lib) ]
endforeach

__common_hex_deps = [ ]

__common_hex_lib = static_library ('wakit-common-hex',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Common.Hex"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Common.Hex"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_dep, gobject_dep ],
  sources: __common_hex_src,
  vala_args: [ '--includedir', meson.current_build_dir ().replace (base_dir + '/', '') ])

__common_hex_dep = declare_dependency (dependencies: [ config_dep, gobject_dep ],
  link_with: __common_hex_lib)