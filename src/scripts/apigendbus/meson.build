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

inja_dep = dependency ('inja', required: true)
nlohmann_json_dep = dependency ('nlohmann_json', required: true)

__apigen_dbus_src = [ 'genimpl.h', 'typenameinargs.cc', 'typenameoutargs.cc' ]

foreach bit: [ 'dbusinfo', 'dbusinfogenerator', 'dbusinfoimporter' ] 

  __apigen_dbus_src += [ '@0@.cc'.format (bit) ]
  __apigen_dbus_src += [ '@0@.h'.format (bit) ]
endforeach

__apigen_dbus_lib = static_library ('wakit-scripts-apigen-dbus',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Scripts.ApiGen.DBus"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Scripts.ApiGen.DBus"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_pch: 'pch/pch.h',
  dependencies: [ config_dep, gio_dep, inja_dep, nlohmann_json_dep ],
  sources: __apigen_dbus_src)

__apigen_dbus_dep = declare_dependency (dependencies: [ config_dep ],
  link_with: __apigen_dbus_lib)