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

gcrypt_dep = cc.find_library ('libgcrypt', required: true)

__common_krypt_gcrypt_src = [ ]

foreach lib: [ 'gcryptapi' ]

  __common_krypt_gcrypt_src += [ '@0@.cc'.format (lib) ]
  __common_krypt_gcrypt_src += [ '@0@.h'.format (lib) ]
endforeach

foreach lib: [ 'gcryptapi' ]

  __common_krypt_gcrypt_src += [ '@0@.vala'.format (lib) ]
endforeach

__common_krypt_gcrypt_fwds = []

foreach lib: [ 'checksum', 'curve', 'cipher', 'export', 'gcryptapi', 'kdf', 'prime', 'random', 'scalar' ]

  __common_krypt_gcrypt_src += [ '@0@.vapi'.format (lib) ]
  __common_krypt_gcrypt_fwds += [ '@0@.vapi'.format (lib) ]
endforeach

__common_krypt_gcrypt_deps = [ gcrypt_dep ]

__common_krypt_gcrypt_lib = static_library ('wakit-common-krypt-gcrypt',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Common.Krypt.GCrypt"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Common.Krypt.GCrypt"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_dep, gio_dep, __common_krypt_gcrypt_deps ],
  sources: __common_krypt_gcrypt_src,
  vala_args: [ '--includedir', meson.current_build_dir ().replace (base_dir + '/', '') ])

__common_krypt_gcrypt_dep = declare_dependency (dependencies: [ config_dep, gio_dep ],
  link_with: __common_krypt_gcrypt_lib, sources: __common_krypt_gcrypt_fwds)