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

gmodule_dep = dependency ('gmodule-2.0', required: true)

__host_module_src = [ ]

foreach bit: [ 'arguments', 'module', 'modulehost', 'typemodule' ]

  __host_module_src += [ '@0@.vala'.format (bit) ]
endforeach

foreach bit: [ 'module' ]

  __host_module_src += [ '@0@.cc'.format (bit), '@0@.h'.format (bit) ]
endforeach

__host_module_client_deps = [ __common_dep ]

__host_module_client_lib = static_library ('wakit-host-module-client',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Host.Module"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()), ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Host.Module"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_vala_dep, json_dep, gmodule_dep, __host_module_client_deps ],
  sources: __host_module_src,
  vala_args: [ '--includedir', meson.current_build_dir ().replace (base_dir + '/', '') ])

__host_module_client_dep = declare_dependency (dependencies: [ config_dep, __common_dep ],
  link_with: __host_module_client_lib)

__host_module_client_deps = [ __common_dep ]

__host_module_client_exe = executable ('wakit-host-module-host',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Host.Module.Host"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Host.Module.Host"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_vala_dep, json_dep, __host_module_client_dep, __host_module_client_deps ],
  install: true,
  install_dir: libexec_dir,
  install_rpath: lib_dir,
  sources: [ 'host.vala', 'hostapplication.vala' ],
  vala_args: [ '--includedir', meson.current_build_dir ().replace (base_dir + '/', '') ])

__host_module_server_deps = [ __common_dep, __host_configuration_dep, __core_dep, __core_process_dep ]

__host_module_server_lib = static_library ('wakit-host-module-server',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Host.Module"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()), ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Host.Module"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_vala_dep, __host_module_client_dep, __host_module_server_deps ],
  sources: [ 'registry.cc', 'registry.h', 'registry.vala', 'registrypostable.vala', 'watcher.vala' ],
  vala_args: [ '--includedir', meson.current_build_dir ().replace (base_dir + '/', '') ])

__host_module_server_dep = declare_dependency (dependencies: [ config_dep, __host_module_client_dep ],
  link_with: __host_module_server_lib)

__host_module_dep = declare_dependency (dependencies: [ config_dep, __host_module_client_dep, __host_module_server_dep ])