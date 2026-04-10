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

__host_interfaces_src = [ ]

foreach lib: [ ]

  __host_interfaces_src += [ '@0@.c'.format (lib) ]
  __host_interfaces_src += [ '@0@.h'.format (lib) ]
endforeach

foreach lib: [ 'browser', 'webview' ]

  __host_interfaces_src += [ '@0@.vala'.format (lib) ]
endforeach

__host_interfaces_lib = static_library ('wakit-host-interfaces',
  c_args: [ '-DG_LOG_DOMAIN="WaKit.Host.Interfaces"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_vala_dep, gtk_dep, __utility_dep ],
  sources: __host_interfaces_src)

__host_interfaces_dep = declare_dependency (dependencies: [ config_dep, gtk_dep ],
  include_directories: include_directories ('.'),
  link_with: __host_interfaces_lib)