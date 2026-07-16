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

__core_loaders_src = [ ]

foreach lib: [ ]

  __core_loaders_src += [ '@0@.cc'.format (lib) ]
  __core_loaders_src += [ '@0@.h'.format (lib) ]
endforeach

foreach lib: [ 'register' ]

  __core_loaders_src += [ '@0@.vala'.format (lib) ]
endforeach

foreach lib: [ '', 'absolute', 'regex', 'verbatim' ]

  __core_loaders_src += [ '@0@alias.vala'.format (lib) ]
endforeach

foreach lib: [ '', 'bundle', 'tree' ]

  __core_loaders_src += [ '@0@loader.vala'.format (lib) ]
endforeach

__core_loaders_deps = [ __common_dep,
                        __core_interfaces_dep ]

__core_loaders_lib = static_library ('wakit-core-loaders',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Core.Loader"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Core.Loader"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_vala_dep, gio_dep, __core_loaders_deps ],
  sources: __core_loaders_src,
  vala_args: [ '--includedir', meson.current_build_dir ().replace (base_dir + '/', '') ])

__core_loaders_dep = declare_dependency (dependencies: [ config_dep, gio_dep, __common_dep ],
  link_with: __core_loaders_lib)

__core_apploader_incdir = include_dir / meson.current_build_dir ().replace (base_dir + '/', '')

install_headers (__core_loaders_lib.vala_header (), install_dir: __core_apploader_incdir, preserve_path: true)