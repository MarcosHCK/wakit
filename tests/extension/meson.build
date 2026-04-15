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

jsc_dep = dependency ('javascriptcoregtk-6.0', required: true)

__testing_extension_src = [ ]

foreach lib: [ 'testing' ]

  __testing_extension_src += [ '@0@.cc'.format (lib) ]
  __testing_extension_src += [ '@0@.h'.format (lib) ]
endforeach

__testing_extension_lib = static_library ('testing-extension',
  c_args: [ '-DG_LOG_DOMAIN="Testing.Extension"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Testing.Extension"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  build_by_default: false,
  dependencies: [ config_dep, glib_dep, jsc_dep ],
  sources: __testing_extension_src)

__testing_extension_dep = declare_dependency (dependencies: [ config_dep, glib_dep, jsc_dep ],
  link_with: __testing_extension_lib)

subdir ('utility')