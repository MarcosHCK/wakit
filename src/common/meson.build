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

# level 1
subdir ('asynchelp')
subdir ('enum')
subdir ('hex')

# level 2
subdir ('krypt')

# level 3
subdir ('appbus')

gio_unix_dep = dependency ('gio-unix-2.0', required: false)
gio_win32_dep = dependency ('gio-win32-2.0', required: false)

json_dep = dependency ('json-glib-1.0', required: true)

__common_src = [ 'bits.h', 'boxing.h', 'constmap.h', 'constpairs.h', 'mixin.h', 'slice.h', 'value.h' ]

foreach lib: [ 'commandline' ]

  __common_src += [ '@0@.cc'.format (lib) ]
  __common_src += [ '@0@.h'.format (lib) ]
endforeach

foreach lib: [ 'genericset', 'list', 'ptrarray' ]

  __common_src += [ '@0@collection.vala'.format (lib) ]
endforeach

foreach lib: [ 'guest', 'host' ]

  __common_src += [ 'extensiondata@0@.vala'.format (lib) ]
endforeach

foreach lib: [ 'collection', 'collectioniter', 'commandline', 'resource', 'standardfiles', 'variant' ]

  __common_src += [ '@0@.vala'.format (lib) ]
endforeach

__common_deps = [ __common_appbus_dep.as_link_whole (),
                  __common_asynchelp_dep.as_link_whole (),
                  __common_enum_dep.as_link_whole (),
                  __common_hex_dep.as_link_whole (),
                  __common_krypt_dep.as_link_whole (), ]

__common_fwds = [ __common_appbus_dep,
                  __common_asynchelp_dep,
                  __common_enum_dep, ]

if gio_unix_dep.found ()
  __common_deps += [ gio_unix_dep ]
  __common_fwds += [ gio_unix_dep ]
endif

if gio_win32_dep.found ()
  __common_deps += [ gio_win32_dep ]
  __common_fwds += [ gio_win32_dep ]
endif

__common_lib = library ('wakit-common',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Common"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Common"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_dep, gio_dep, __common_deps ],
  sources: __common_src,
  vala_args: [ '--includedir', meson.current_build_dir ().replace (base_dir + '/', '') ])

__common_dep = declare_dependency (dependencies: [ config_dep, gio_dep, __common_fwds ],
  link_with: __common_lib)

meson.override_dependency ('wakit-common', __common_dep)