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

# level 0
subdir ('gcrypt')

# level 1
subdir ('cookieauth')

__common_krypt_src = [ ]

foreach lib: [ ]

  __common_krypt_src += [ '@0@.cc'.format (lib) ]
  __common_krypt_src += [ '@0@.h'.format (lib) ]
endforeach

foreach lib: [ 'dummy' ]

  __common_krypt_src += [ '@0@.vala'.format (lib) ]
endforeach

__common_krypt_deps = [ gcrypt_dep,
                        __common_krypt_cookieauth_dep.as_link_whole (),
                        __common_krypt_gcrypt_dep.as_link_whole (), ]

__common_krypt_fwds = [ __common_krypt_cookieauth_dep,
                        __common_krypt_gcrypt_dep, ]

__common_krypt_lib = static_library ('wakit-common-krypt',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Common.Krypt"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Common.Krypt"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_dep, gio_dep, __common_krypt_deps ],
  sources: __common_krypt_src,
  vala_args: [ '--includedir', meson.current_build_dir ().replace (base_dir + '/', '') ])

__common_krypt_dep = declare_dependency (dependencies: [ config_dep, gio_dep, __common_krypt_fwds ],
  link_with: __common_krypt_lib)

__common_krypt_incdir = include_dir / meson.current_build_dir ().replace (base_dir + '/', '')

install_headers (__common_krypt_lib.vala_header (), install_dir: __common_krypt_incdir, preserve_path: true)