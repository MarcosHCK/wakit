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

__host_simple_src = [ ]

foreach bit: [ 'application' ]

  __host_simple_src += [ '@0@.cc'.format (bit) ]
  __host_simple_src += [ '@0@.h'.format (bit) ]
endforeach

foreach bit: [ 'application', 'host', 'window' ]

  __host_simple_src += [ '@0@.vala'.format (bit) ]
endforeach

__host_simple_deps = [ __common_dep, __core_dep,
                       __host_simple_configuration_dep.as_link_whole () ]

__host_simple_fwds = [ __core_dep,
                       __host_simple_configuration_dep ]

__host_simple_src += import ('gnome').compile_resources ('wakit-host-simple-resoures',
  'resources.xml',
  c_name: 'wakit_host_simple',
  export: false,
  source_dir: meson.current_source_dir ())

__host_simple_lib = library ('wakit-host-simple',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Host.Simple"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Host.Simple"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_vala_dep, gtk_dep, __host_simple_deps ],
  sources: __host_simple_src,
  vala_args: [ '--includedir', meson.current_build_dir ().replace (base_dir + '/', '') ])

__host_simple_dep = declare_dependency (dependencies: [ config_dep, gtk_dep, __common_dep, __host_simple_fwds ],
  link_with: __host_simple_lib)

meson.override_dependency ('wakit-host-simple', __host_simple_dep)

__host_simple_bin = executable ('wakit-host-simple-app',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Host.Simple.App"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Host.Simple.App"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_dep, gtk_dep, __host_simple_dep ],
  sources: 'main.cc',
  vala_args: [ '--includedir', meson.current_build_dir ().replace (base_dir + '/', '') ])

__host_simple_runner_cfg = configuration_data ()

__host_simple_runner_cfg.set ('host_simple_bin_path', __host_simple_bin.full_path ())

foreach tuple: [ [ __common_lib, 'common_lib_path' ],
                 [ __extension_lib, 'extension_lib_path' ],
                 [ __extension_mod, 'extension_mod_path' ],
                 [ __core_lib, 'host_lib_path' ],
                 [ __host_simple_lib, 'host_simple_lib_path' ] ]

  path = tuple.get (0).full_path ()
  list = path.split ('/')

  path = path.replace (list.get (list.length () - 1), '')

  __host_simple_runner_cfg.set (tuple.get (1), path)

endforeach

configure_file (configuration: __host_simple_runner_cfg, input: 'runner.sh.in', output: 'runner.sh')