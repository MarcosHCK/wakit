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

subdir ('configuration')
subdir ('module')

__host_src = [ ]

foreach bit: [ 'application' ]

  __host_src += [ '@0@.cc'.format (bit) ]
  __host_src += [ '@0@.h'.format (bit) ]
endforeach

foreach bit: [ 'application', 'runner', 'window' ]

  __host_src += [ '@0@.vala'.format (bit) ]
endforeach

__host_deps = [ __common_dep,
                __core_dep,
                __host_configuration_dep.as_link_whole (),
                __host_module_dep.as_link_whole (), ]

__host_fwds = [ __core_dep,
                __host_configuration_dep,
                __host_module_dep ]

__host_c_args = [
  '-DMODULE_HOST_BIN_PATH="@0@"'.format (libexec_dir / __host_module_client_exe.name ()),
]

__host_src += import ('gnome').compile_resources ('wakit-host-resoures',
  'resources.xml',
  c_name: 'wakit_host',
  export: false,
  source_dir: meson.current_source_dir ())

__host_lib = library ('wakit-host',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Host"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ] + __host_c_args,
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Host"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ] + __host_c_args,
  dependencies: [ config_vala_dep, gtk_dep, __host_deps ],
  install: true,
  install_dir: lib_dir,
  install_rpath: lib_dir,
  sources: __host_src,
  vala_args: [ '--includedir', 'wakit' / meson.current_build_dir ().replace (base_dir + '/', '') ])

__host_dep = declare_dependency (dependencies: [ config_dep, gtk_dep, __common_dep, __host_fwds ],
  link_with: __host_lib)

import ('pkgconfig').generate (__host_lib,
  libraries: [ __host_dep ],
  version: meson.project_version ())

__host_incdir = include_dir / meson.current_build_dir ().replace (base_dir + '/', '')

install_headers (__host_lib.vala_header (), install_dir: __host_incdir, preserve_path: true)
meson.override_dependency ('wakit-host', __host_dep)

__host_bin = executable ('wakit-host-app',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Host.App"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Host.App"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_dep, gtk_dep, __host_dep ],
  install: true,
  install_dir: bin_dir,
  install_rpath: lib_dir,
  sources: 'main.cc',
  vala_args: [ '--includedir', 'wakit' / meson.current_build_dir ().replace (base_dir + '/', '') ])

__host_runner_cfg = configuration_data ()

__host_runner_cfg.set ('busmaster_bin_path', __busmaster_exe.full_path ())
__host_runner_cfg.set ('busmaster_config_path', __core_appbus_src_dir / __core_appbus_config)
__host_runner_cfg.set ('host_bin_path', __host_bin.full_path ())
__host_runner_cfg.set ('module_host_bin_path', __host_module_client_exe.full_path ())

foreach tuple: [ [ __common_lib, 'common_lib_path' ],
                 [ __core_lib, 'core_lib_path' ],
                 [ __extension_lib, 'extension_lib_path' ],
                 [ __extension_mod, 'extension_mod_path' ],
                 [ __host_lib, 'host_lib_path' ] ]

  path = tuple.get (0).full_path ()
  list = path.split ('/')

  path = path.replace (list.get (list.length () - 1), '')

  __host_runner_cfg.set (tuple.get (1), path)
endforeach

configure_file (configuration: __host_runner_cfg, input: 'runner.sh.in', output: 'runner.sh')
