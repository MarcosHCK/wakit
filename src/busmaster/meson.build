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

subdir ('bus')
subdir ('transport')

__busmaster_src = [ ]

foreach bit: [ ]

  __busmaster_src += [ '@0@.cc'.format (bit) ]
  __busmaster_src += [ '@0@.h'.format (bit) ]
endforeach

foreach bit: [ 'application', 'configuration' ]

  __busmaster_src += [ '@0@.vala'.format (bit) ]
endforeach

__busmaster_deps = [ __common_dep,
                     __busmaster_bus_dep.as_link_whole (),
                     __busmaster_transport_dep.as_link_whole (), ]

__busmaster_exe = executable ('wakit-busmaster',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.BusMaster"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.BusMaster"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_dep, gio_dep, json_dep, __busmaster_deps ],
  sources: __busmaster_src,
  vala_args: [ '--includedir', meson.current_build_dir ().replace (base_dir + '/', '') ])

meson.override_find_program ('wakit-busmaster', __busmaster_exe)