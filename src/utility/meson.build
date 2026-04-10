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

gio_dep = dependency ('gio-2.0', required: true)

__utility_src = []

foreach lib: [ ]

  __utility_src += [ '@0@.c'.format (lib) ]
  __utility_src += [ '@0@.h'.format (lib) ]
endforeach

foreach lib: [ 'timeoutcancellable' ]

  __utility_src += [ '@0@.vala'.format (lib) ]
endforeach

__utility_lib = library ('wakit-utility',
  c_args: [ '-DG_LOG_DOMAIN="WaKit.Utility"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_dep, gio_dep ],
  sources: __utility_src)

__utility_dep = declare_dependency (dependencies: [ config_dep, gio_dep ],
  include_directories: include_directories ('.'),
  link_with: __utility_lib)