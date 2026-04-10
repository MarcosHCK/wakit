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

__host_process_src = [ 'process.vala', 'watcher.vala' ]

foreach lib: [ 'impl' ]

  __host_process_src += [ '@0@.c'.format (lib) ]
  __host_process_src += [ '@0@.h'.format (lib) ]
endforeach

__host_process_deps = [ __utility_dep ]

__host_process_lib = static_library ('wakit-host-process',
  c_args: [ '-DG_LOG_DOMAIN="WaKit.Host.Process"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_vala_dep, gio_dep, __host_process_deps ],
  sources: __host_process_src)

__host_process_dep = declare_dependency (dependencies: [ config_dep, gio_dep ],
  include_directories: include_directories ('.'),
  link_with: __host_process_lib)