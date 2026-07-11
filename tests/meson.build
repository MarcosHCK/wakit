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

basepath = meson.current_source_dir ()
testpathroot = '/org/hck/wakit'

__testing_src = [ ]

foreach lib: [ 'testing' ]

  __testing_src += [ '@0@.cc'.format (lib) ]
  __testing_src += [ '@0@.h'.format (lib) ]
endforeach

__testing_lib = static_library ('testing',
  c_args: [ '-DG_LOG_DOMAIN="Testing"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Testing"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_pch: 'pch/pch.h',
  build_by_default: false,
  dependencies: [ config_dep, glib_dep ],
  include_directories: include_directories ('.'),
  sources: __testing_src)

__testing_dep = declare_dependency (dependencies: [ config_dep, glib_dep ],
  include_directories: include_directories ('.'),
  link_with: __testing_lib)

foreach bit: [ 'common', 'core', 'extension' ]

  subdir (bit)
endforeach