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

ffi_dep = cc.find_library ('libffi', required: true)

__common_ffi_src = [ 'primitives.h' ]

foreach bit: [ 'cfi', 'cfitype' ] 

  __common_ffi_src += [ 'function@0@.h'.format (bit) ]
endforeach

foreach bit: [ 'destroynotify', 'function' ] 

  __common_ffi_src += [ '@0@.cc'.format (bit) ]
  __common_ffi_src += [ '@0@.h'.format (bit) ]
endforeach

__common_ffi_deps = []

__common_ffi_lib = static_library ('wakit-common-ffi',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Common.FFI"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Common.FFI"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_dep, ffi_dep, glib_dep, __common_ffi_deps ],
  sources: __common_ffi_src,
  vala_args: [ '--includedir', 'wakit' / meson.current_build_dir ().replace (base_dir + '/', '') ])

__common_ffi_dep = declare_dependency (dependencies: [ config_dep, ffi_dep ],
  link_with: __common_ffi_lib)