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

__common_appbus_src = [ ]

foreach lib: [ 'address', 'ownname' ]

  __common_appbus_src += [ '@0@.cc'.format (lib) ]
  __common_appbus_src += [ '@0@.h'.format (lib) ]
endforeach

foreach lib: [ 'address', 'addressoption', 'addressstring', 'connectclient', 'connectserver', 'cookie', 'ownname' ]

  __common_appbus_src += [ '@0@.vala'.format (lib) ]
endforeach

__common_appbus_deps = [ __common_asynchelp_dep,
                         __common_krypt_dep, ]

__common_appbus_fwds = [ __common_krypt_dep, ]

__common_appbus_lib = static_library ('wakit-common-appbus',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Common.AppBus"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Common.AppBus"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_dep, gio_dep, __common_appbus_deps ],
  sources: __common_appbus_src,
  vala_args: [ '--includedir', meson.current_build_dir ().replace (base_dir + '/', '') ])

__common_appbus_dep = declare_dependency (dependencies: [ config_dep, gio_dep, __common_appbus_fwds ],
  link_with: __common_appbus_lib)