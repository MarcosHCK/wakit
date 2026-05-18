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

webkit_dep = dependency ('webkitgtk-6.0', required: true)

__core_browser_src = [ ]

foreach bit: [ ]

  __core_browser_src += [ '@0@.cc'.format (bit) ]
  __core_browser_src += [ '@0@.h'.format (bit) ]
endforeach

foreach bit: [ 'browser', 'dragcontroller', 'extensionhost', 'resource', 'urirequest', 'widget', 'window', 'windowregistrar' ]

  __core_browser_src += [ '@0@.vala'.format (bit) ]
endforeach

__core_browser_bundle = []

foreach bit: [ 'browser' ]

  __core_browser_bundle += esbuild_css_gen.process ('@0@.css'.format (bit))
  __core_browser_bundle += esbuild_js_gen.process ('@0@.ts'.format (bit))
endforeach

__core_browser_src += custom_target ('wakit-core-browser-resources',
  command: [ python_exe,
             mkresources_py,
             '--basedir', '@PRIVATE_DIR@',
             '--bin', resources_exe.full_path (),
             '--dep', '@DEPFILE@',
             '--header', '@OUTPUT0@',
             '--source', '@OUTPUT1@',
             '--name', 'wakit_browser_',
             '-s', '/org/hck/wakit/browser/', '@INPUT@' ],
  depfile: 'resources.deps',
  input: __core_browser_bundle,
  output: [ 'resources.bundle.h', 'resources.bundle.c' ])

__core_browser_deps = [ __common_dep,
                        __core_configuration_dep,
                        __core_gui_dep,
                        __core_interfaces_dep ]

__core_browser_lib = static_library ('wakit-core-browser',
  c_args: [ '-DG_LOG_DOMAIN="Wakit.Core.Browser"', '-DG_LOG_USE_STRUCTURED=1',
            '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
            '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  cpp_args: [ '-DG_LOG_DOMAIN="Wakit.Core.Browser"', '-DG_LOG_USE_STRUCTURED=1',
              '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
              '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()) ],
  dependencies: [ config_vala_dep, webkit_dep, __core_browser_deps ],
  sources: __core_browser_src,
  vala_args: [ '--includedir', meson.current_build_dir ().replace (base_dir + '/', '') ])

__core_browser_dep = declare_dependency (dependencies: [ config_dep, webkit_dep ],
  link_with: __core_browser_lib)