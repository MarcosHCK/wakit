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

mkresources_py = meson.current_source_dir () / 'mkresources.py'