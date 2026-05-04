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

subdir ('apigendbus')
subdir ('introspectdbus')

python_exe = import ('python').find_installation ('python3')

esbuild_exe = find_program ('esbuild', required: true)
resources_exe = find_program ('glib-compile-resources', required: true)

esbuild_py = meson.current_source_dir () / 'esbuild.py'

esbuild_css_gen = generator (python_exe, 
  arguments: [ esbuild_py,
               '--bin', esbuild_exe.full_path (),
               '--dep', '@DEPFILE@',
               '@EXTRA_ARGS@', '@INPUT@', '@OUTPUT@' ],
  depfile: '@BASENAME@.deps',
  output: '@BASENAME@.min.css')

esbuild_js_gen = generator (python_exe, 
  arguments: [ esbuild_py,
               '--bin', esbuild_exe.full_path (),
               '--dep', '@DEPFILE@',
               '@EXTRA_ARGS@', '@INPUT@', '@OUTPUT@' ],
  depfile: '@BASENAME@.deps',
  output: '@BASENAME@.min.js')

apigen_dbus_exe = executable ('apigen-dbus',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Scripts.ApiGen.DBus"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Scripts.ApiGen.DBus"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_pch: 'pch/apigen-dbus.h',
  dependencies: [ config_dep, gio_dep, __apigen_dbus_dep ],
  sources: 'apigendbus.cc')

introspect_dbus_exe = executable ('introspect-dbus',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Scripts.Introspect.DBus"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Scripts.Introspect.DBus"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_pch: 'pch/introspect-dbus.h',
  dependencies: [ config_dep, gio_dep, __introspect_dbus_dep ],
  sources: 'introspectdbus.cc', )

apigen_py = meson.current_source_dir () / 'apigen.py'

apigen_gen = generator (python_exe, 
  arguments: [ apigen_py,
               '--apigen-bin', apigen_dbus_exe.full_path (),
               '--introspect-bin', introspect_dbus_exe.full_path (),
               '@EXTRA_ARGS@', '@INPUT@', '@OUTPUT@' ],
  depends: [ apigen_dbus_exe, introspect_dbus_exe ],
  output: '@BASENAME@.d.ts')

mkresources_py = meson.current_source_dir () / 'mkresources.py'