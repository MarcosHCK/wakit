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

__core_gui_src = [ ]

foreach bit: []

  __core_gui_src += [ '@0@.c'.format (bit) ]
  __core_gui_src += [ '@0@.h'.format (bit) ]
endforeach

foreach bit: [ 'message' ]

  __core_gui_src += [ '@0@.vala'.format (bit) ]
endforeach

__core_gui_src += import ('gnome').compile_resources ('wakit-core-gui-resoures',
  'resources.xml',
  c_name: 'wakit_gui',
  export: false,
  source_dir: meson.current_source_dir ())

__core_gui_deps = [ __common_dep ]

__core_gui_lib = static_library ('wakit-core-gui',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Core.Gui"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Core.Gui"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_vala_dep, gtk_dep, __core_gui_deps ],
  sources: __core_gui_src,
  vala_args: [ '--includedir', 'wakit' / meson.current_build_dir ().replace (base_dir + '/', '') ])

__core_gui_dep = declare_dependency (dependencies: [ config_dep, gtk_dep, __common_dep ],
  link_with: __core_gui_lib)