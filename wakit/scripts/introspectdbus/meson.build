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

lief_dep = dependency ('LIEF', required: true)

nlohmann_json_dep = dependency ('nlohmann_json', required: true)

__introspect_dbus_src = []

foreach bit: [ 'dbusinfoexplorer', 'dbusinfoexporter', 'explorer' ] 

  __introspect_dbus_src += [ '@0@.cc'.format (bit) ]
  __introspect_dbus_src += [ '@0@.h'.format (bit) ]
endforeach

__introspect_dbus_lib = static_library ('wakit-scripts-introspect-dbus',
  build_by_default: get_option ('buildtools'),
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Scripts.Introspect.DBus"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Scripts.Introspect.DBus"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_pch: 'pch/pch.h',
  dependencies: [ config_dep, gio_dep, lief_dep, nlohmann_json_dep ],
  sources: __introspect_dbus_src)

__introspect_dbus_dep = declare_dependency (dependencies: [ config_dep, gio_dep ],
  link_with: __introspect_dbus_lib)