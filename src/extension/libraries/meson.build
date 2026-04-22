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

foreach bit: [ 'logging' ]

  __extension_libraries_src += [ '@0@.vala'.format (bit) ]
endforeach

foreach bit: [ 'logging' ]

  name = '@0@_js'.format (bit)
  source = '@0@.js'.format (bit)

  __extension_libraries_src += jscompiler_gen.process (source, extra_args: [ '-n', name ])
endforeach

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