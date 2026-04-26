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

__extension_libraries_src = [ ]

foreach bit: [ 'logging' ]

  __extension_libraries_src += [ '@0@.cc'.format (bit) ]
  __extension_libraries_src += [ '@0@.h'.format (bit) ]
endforeach

foreach bit: [ 'logging', 'resources' ]

  __extension_libraries_src += [ '@0@.vala'.format (bit) ]
endforeach

__extension_libraries_bundle = []

foreach bit: [ 'logging' ]

  __extension_libraries_bundle += esbuild_js_gen.process ('@0@.ts'.format (bit))
endforeach

__extension_libraries_src += custom_target ('wakit-extension-libraries-resources',
  command: [ python_exe,
             mkresources_py,
             '--basedir', '@PRIVATE_DIR@',
             '--bin', resources_exe.full_path (),
             '--dep', '@DEPFILE@',
             '--header', '@OUTPUT0@',
             '--source', '@OUTPUT1@',
             '--name', 'wakit_libraries_',
             '-s', '/org/hck/wakit/extension/libraries/', '@INPUT@' ],
  depfile: 'resources.deps',
  input: __extension_libraries_bundle,
  output: [ 'resources.bundle.h', 'resources.bundle.c' ])

__extension_libraries_deps = [ __common_dep,
                              __extension_utility_dep, ]

__extension_libraries_lib = static_library ('wakit-extension-libraries',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Extension.Libraries"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Extension.Libraries"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_pch: 'pch/pch.h',
  dependencies: [ config_vala_dep, webkitext_dep, __extension_libraries_deps ],
  sources: __extension_libraries_src,
  vala_args: [ '--includedir', meson.current_build_dir ().replace (base_dir + '/', '') ])

__extension_libraries_dep = declare_dependency (dependencies: [ config_dep, webkitext_dep ],
  link_with: __extension_libraries_lib)