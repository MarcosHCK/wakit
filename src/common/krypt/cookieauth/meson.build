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

__common_krypt_cookieauth_src = [ 'internal.h' ]

foreach lib: [ ]

  __common_krypt_cookieauth_src += [ '@0@.cc'.format (lib) ]
  __common_krypt_cookieauth_src += [ '@0@.h'.format (lib) ]
endforeach

foreach lib: [ 'challenge', 'client', 'cookie', 'server', 'protocol', 'response' ]

  __common_krypt_cookieauth_src += [ '@0@.vala'.format (lib) ]
endforeach

__common_krypt_cookieauth_deps = [ gcrypt_dep,
                                   __common_hex_dep,
                                   __common_krypt_gcrypt_dep,
                                   __common_krypt_gcrypt_vapi_dep, ]

__common_krypt_cookieauth_lib = static_library ('wakit-common-krypt-cookieauth',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Common.Krypt.CookieAuth"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Common.Krypt.CookieAuth"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_dep, gio_dep, __common_krypt_cookieauth_deps ],
  sources: __common_krypt_cookieauth_src,
  vala_args: [ '--includedir', meson.current_build_dir ().replace (base_dir + '/', '') ])

__common_krypt_cookieauth_dep = declare_dependency (dependencies: [ config_dep, gio_dep ],
  link_with: __common_krypt_cookieauth_lib)

__common_krypt_cookieauth_incdir = include_dir / meson.current_build_dir ().replace (base_dir + '/', '')

install_headers (__common_krypt_cookieauth_lib.vala_header (), install_dir: __common_krypt_cookieauth_incdir, preserve_path: true)