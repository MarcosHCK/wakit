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

xxd_exe = find_program ('xxd', required: false)

if not xxd_exe.found ()

  python = import ('python')
  python = python.find_installation ('python3')

  xxd_gen = meson.current_source_dir () / 'xxd.py'
  xxd_gen = generator (python, arguments: [ xxd_gen, '-i', '@EXTRA_ARGS@', '@INPUT@' ], capture: true, output: '@PLAINNAME@.c')

  xxd_exe = python.full_path () + ' ' + meson.current_source_dir () / 'xxd.py'
else

  xxd_gen = generator (xxd_exe, arguments: [ '-i', '@EXTRA_ARGS@', '@INPUT@' ], capture: true, output: '@PLAINNAME@.c')
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
                                      output: '@PLAINNAME@.c')
endif

subdir ('appbus')

__common_src = [ 'bits.h', 'boxing.h', 'mixin.h' ]

foreach lib: [ 'enum' ]

  __common_src += [ '@0@.cc'.format (lib) ]
  __common_src += [ '@0@.h'.format (lib) ]
endforeach

foreach lib: [ 'enum', 'timeoutcancellable' ]

  __common_src += [ '@0@.vala'.format (lib) ]
endforeach

__common_deps = [ __common_appbus_dep.as_link_whole () ]

__common_lib = library ('wakit-common',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Common"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Common"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_dep, gio_dep, __common_deps ],
  sources: __common_src,
  vala_args: [ '--includedir', meson.current_build_dir ().replace (base_dir + '/', '') ])

__common_dep = declare_dependency (dependencies: [ config_dep, gio_dep ],
  link_with: __common_lib)

meson.override_dependency ('wakit-common', __common_dep)