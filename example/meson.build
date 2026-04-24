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

__example_src = [ ]

foreach bit: [ 'application', 'interface' ]

  __example_src += [ '@0@.vala'.format (bit) ]
endforeach

__example_bin = executable ('wakit-example',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Example"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_vala_dep, __host_dep ],
  sources: __example_src)

__example_cfg = configuration_data ()

__example_cfg.set ('example_bin', __example_bin.full_path ())

foreach tuple: [ [ __common_lib, 'common_lib_path' ],
                 [ __extension_lib, 'extension_lib_path' ],
                 [ __extension_mod, 'extension_mod_path' ],
                 [ __host_lib, 'host_lib_path' ] ] 

  tgt = tuple.get (0)

  path = tgt.full_path ()
  list = path.split ('/')

  path = path.replace (list.get (list.length () - 1), '')

  __example_cfg.set (tuple.get (1), path)

endforeach

configure_file (configuration: __example_cfg, input: 'runner.sh.in', output: 'runner.sh')