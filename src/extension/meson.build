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

gmodule_dep = dependency ('gmodule-2.0', required: true)
webkitext_dep = dependency ('webkitgtk-web-process-extension-6.0', required: true)

# level 0
subdir ('utility')

# level 1
subdir ('binding')
subdir ('bindings')
subdir ('libraries')

__extension_src = [ 'extension.cc', 'extension.hh', 'resource.cc' ]

foreach bit: []

  __extension_src += [ '@0@.c'.format (bit) ]
  __extension_src += [ '@0@.h'.format (bit) ]
endforeach

foreach bit: [ 'extension', 'module' ]

  __extension_src += [ '@0@.vala'.format (bit) ]
endforeach

__extension_deps = [ __common_dep,
                     __extension_binding_dep.as_link_whole (),
                     __extension_bindings_dep.as_link_whole (),
                     __extension_libraries_dep.as_link_whole (),
                     __extension_utility_dep.as_link_whole (), ]

__extension_lib = library ('wakit-extension',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Extension"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Extension"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_vala_dep, webkitext_dep, __extension_deps ],
  install: true,
  install_dir: lib_dir,
  install_rpath: lib_dir,
  sources: __extension_src,
  vala_args: [ '--includedir', meson.current_build_dir ().replace (base_dir + '/', '') ])

__extension_dep = declare_dependency (dependencies: [ config_dep, webkitext_dep ],
  link_with: __extension_lib)

import ('pkgconfig').generate (__extension_lib,
  libraries: [ __extension_dep ],
  version: meson.project_version ())

__extension_incdir = include_dir / meson.current_build_dir ().replace (base_dir + '/', '')

install_headers (__extension_lib.vala_header (), install_dir: __extension_incdir, preserve_path: true)
meson.override_dependency ('wakit-extension', __extension_dep)

__extension_mod = shared_module ('wakit-extension-mod',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Extension.Module"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Extension.Module"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_dep, gmodule_dep, __extension_dep ],
  install: true,
  install_dir: extension_dir,
  install_rpath: lib_dir,
  sources: 'module.cc')