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

xxd_exe = find_program ('xxd', required: false)

if not xxd_exe.found ()

  python = import ('python')
  python = python.find_installation ('python3')

  xxd_exe = python.full_path () + ' ' + meson.current_source_dir () / 'xxd.py'
else

  xxd_exe = xxd_exe.full_path ()
endif

esbuild_exe = find_program ('esbuild', required: true)

if true

  python = import ('python')
  python = python.find_installation ('python3')

  jscompiler_gen = meson.current_source_dir () / 'jscompiler.py'
  jscompiler_gen = generator (python, arguments: [ jscompiler_gen,
                                                   '-b', '@BUILD_DIR@',
                                                   '--esbuild', esbuild_exe.full_path (),
                                                   '--xxd', xxd_exe,
                                                   '@EXTRA_ARGS@', '@INPUT@', '@OUTPUT@' ],
                                      output: '@BASENAME@.hex.c')
endif

__extension_utility_src = [ 'marshalling.h',
                            'marshallingpack.cc',
                            'marshallingunpack.cc', ]

foreach bit: [ 'objectserializer' ]

  name = '@0@_js'.format (bit)
  source = '@0@.ts'.format (bit)

  __extension_utility_src += jscompiler_gen.process (source, extra_args: [ '-n', name ])
endforeach

foreach bit: [ 'promise' ]

  __extension_utility_src += [ '@0@.cc'.format (bit) ]
  __extension_utility_src += [ '@0@.h'.format (bit) ]
endforeach

foreach bit: [ 'error', 'marshalling', 'objectserializer', 'promise' ]

  __extension_utility_src += [ '@0@.vala'.format (bit) ]
endforeach

__extension_utility_deps = [ __common_dep ]

__extension_utility_lib = static_library ('wakit-extension-utility',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Extension.Utility"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Extension.Utility"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_pch: 'pch/pch.h',
  dependencies: [ config_vala_dep, webkitext_dep, __extension_utility_deps ],
  sources: __extension_utility_src,
  vala_args: [ '--includedir', meson.current_build_dir ().replace (base_dir + '/', '') ])

__extension_utility_dep = declare_dependency (dependencies: [ config_dep, webkitext_dep ],
  link_with: __extension_utility_lib)