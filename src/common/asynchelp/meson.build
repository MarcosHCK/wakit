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

__common_asynchelp_src = [ ]

foreach lib: [ 'asyncdelay', 'asynclock' ]

  __common_asynchelp_src += [ '@0@.cc'.format (lib) ]
  __common_asynchelp_src += [ '@0@.h'.format (lib) ]
endforeach

foreach lib: [ 'asyncdelay', 'asynclock', 'timeoutcancellable' ]

  __common_asynchelp_src += [ '@0@.vala'.format (lib) ]
endforeach

__common_asynchelp_deps = [ ]

__common_asynchelp_lib = static_library ('wakit-common-asynchelp',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Common.AsyncHelp"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Common.AsyncHelp"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_dep, gio_dep ],
  sources: __common_asynchelp_src,
  vala_args: [ '--includedir', meson.current_build_dir ().replace (base_dir + '/', '') ])

__common_asynchelp_dep = declare_dependency (dependencies: [ config_dep, gio_dep ],
  link_with: __common_asynchelp_lib)