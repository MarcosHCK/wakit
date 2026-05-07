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

__busmaster_bus_src = [ 'matchmatches.cc', 'matchparse.cc', 'matchelement.vapi' ]

foreach bit: [ 'match' ]

  __busmaster_bus_src += [ '@0@.cc'.format (bit) ]
  __busmaster_bus_src += [ '@0@.h'.format (bit) ]
endforeach

foreach bit: [ 'bus', 'client', 'clientfilter', 'flags', 'match', 'name', 'nameowner', 'server' ]

  __busmaster_bus_src += [ '@0@.vala'.format (bit) ]
endforeach

__busmaster_bus_deps = [ __common_dep ]

__busmaster_bus_lib = static_library ('wakit-busmaster-bus',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.BusMaster.Bus"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.BusMaster.Bus"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_pch: 'pch/pch.h',
  dependencies: [ config_dep, gio_dep, __busmaster_bus_deps ],
  sources: __busmaster_bus_src,
  vala_args: [ '--includedir', meson.current_build_dir ().replace (base_dir + '/', '') ])

__busmaster_bus_dep = declare_dependency (dependencies: [ config_dep, gio_dep ],
  link_with: __busmaster_bus_lib)