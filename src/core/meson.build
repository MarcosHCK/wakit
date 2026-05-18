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

gtk_dep = dependency ('gtk4', required: true)

# level 0
subdir ('interfaces')

# level 1
subdir ('gui')
subdir ('process')

# level 2
subdir ('appbus')
subdir ('apploader')
subdir ('browser')

__core_src = [ ]

foreach bit: []

  __core_src += [ '@0@.c'.format (bit) ]
  __core_src += [ '@0@.h'.format (bit) ]
endforeach

foreach bit: [ 'application', 'deferredurls' ]

  __core_src += [ '@0@.vala'.format (bit) ]
endforeach

__core_deps = [ __common_dep,
                __core_appbus_dep.as_link_whole (),
                __core_browser_dep.as_link_whole (),
                __core_gui_dep.as_link_whole (),
                __core_interfaces_dep.as_link_whole (),
                __core_loaders_dep.as_link_whole (),
                __core_process_dep.as_link_whole () ]

__core_fwds = [ __core_interfaces_dep,
                __core_loaders_dep ]

__core_lib = library ('wakit-core',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Core"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Core"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_vala_dep, gtk_dep, __core_deps ],
  sources: __core_src,
  vala_args: [ '--includedir', meson.current_build_dir ().replace (base_dir + '/', '') ])

__core_dep = declare_dependency (dependencies: [ config_dep, gtk_dep, __common_dep, __core_fwds ],
  link_with: __core_lib)

meson.override_dependency ('wakit-core', __core_dep)