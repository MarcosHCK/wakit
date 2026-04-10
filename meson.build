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

project \
  ( 'wakit', 'c', 'cpp', 'vala',

    default_options: [ 'c_std=c23', 'cpp_std=c++26', 'warning_level=3' ],
    license: 'GPL-3.0-or-later',
    license_files: [ 'COPYING' ],
    meson_version: '>= 1.3.2',

    version: run_command ('version.py', 'get-version', check: true).stdout ().strip ())

cc = meson.get_compiler ('c')
cpp = meson.get_compiler ('cpp')

meson.add_dist_script ('version.py', 'set-dist', meson.project_version ())

git_version = meson.project_version ()
git_version_list = git_version.split ('-')
git_version_list2 = git_version_list.get (0).split ('.')
git_version_major = git_version_list2.get (0)
git_version_minor = git_version_list2.get (1)
git_version_micro = git_version_list2.get (2)
git_version_stage = git_version_list.get (1)

config = configuration_data ()

config.set ('DEBUG', get_option ('debug').to_int ())
config.set ('DEVELOP', get_option ('develop').to_int ())
# TODO: edit this
config.set_quoted ('PACKAGE_BUGREPORT', 'nouser@nohost.com')
config.set_quoted ('PACKAGE_NAME', meson.project_name ())
config.set_quoted ('PACKAGE_STRING', '@0@ @1@'.format (meson.project_name (), meson.project_version ()))
config.set_quoted ('PACKAGE_TARNAME', meson.project_name ())
# TODO: for now
config.set_quoted ('PACKAGE_URL', 'https://github.com/MarcosHCK/wakit')
config.set_quoted ('PACKAGE_VERSION', git_version)
config.set ('PACKAGE_VERSION_MAJOR', git_version_major)
config.set ('PACKAGE_VERSION_MINOR', git_version_minor)
config.set ('PACKAGE_VERSION_MICRO', git_version_micro)
config.set_quoted ('PACKAGE_VERSION_STAGE', git_version_stage)

prefix = get_option ('prefix')

config.set_quoted ('DATA_DIR', prefix / get_option ('datadir') / 'wakit')
config.set_quoted ('LIB_DIR', prefix / get_option ('libdir') / 'wakit')
config.set_quoted ('LIBEXEC_DIR', prefix / get_option ('libexecdir') / 'wakit')

config_dep = declare_dependency (sources: configure_file (output: 'config.h', configuration: config))
config_dep = declare_dependency (dependencies: config_dep, include_directories: include_directories ('.'))

# Common warnings

if cc.get_id () == 'gcc' or cc.get_id () == 'clang'

  warning_c_args = [

    '-Waggregate-return',
    '-Warray-bounds',
    '-Wduplicated-branches',
    '-Werror=format=2',
    '-Werror=implicit-function-declaration',
    '-Werror=init-self',
    '-Werror=missing-prototypes',
    '-Werror=pointer-arith',
    '-Werror=pointer-sign',
    '-Werror=unused-result',
    '-Wimplicit-fallthrough',
    '-Wmisleading-indentation',
    '-Wmissing-field-initializers',
    # Due to pervasive use of things like GPOINTER_TO_UINT(), we do not support
    # building with -Wbad-function-cast.
    '-Wno-bad-function-cast',
    # Due to pervasive use of things like GPOINTER_TO_UINT(), we do not support
    # building with -Wbad-function-cast.
    '-Wno-cast-function-type',
    # A zero-length format string shouldn't be considered an issue.
    '-Wno-format-zero-length',
    # Due to function casts through (void*) we cannot support -Wpedantic:
    # ./docs/toolchain-requirements.md#Function_pointer_conversions.
    '-Wno-pedantic',
    '-Wno-string-plus-int',
    # Due to maintained deprecated code, we do not want to see unused parameters
    '-Wno-unused-parameter',
    # We explicitly require variadic macros
    '-Wno-variadic-macros',
    '-Wnonnull',
    '-Wshadow',
    '-Wstrict-prototypes',
    '-Wunused',
    '-Wunused-function',
    '-Wunused-label',
    '-Wunused-value',
  ]

  warning_c_link_args = [

    '-Wl,-z,nodelete',
  ]
else
  error ('Unsupported compiler')
endif

if get_option ('debug')

  add_project_arguments (([ '-D', 'DEBUG' ]), language: 'vala')
endif

if get_option ('develop')

  add_project_arguments (([ '-D', 'DEVELOP' ]), language: 'vala')
endif

add_project_arguments (cc.get_supported_arguments (warning_c_args), language: 'c')
add_project_link_arguments (cc.get_supported_link_arguments (warning_c_link_args), language: 'c')

add_project_arguments (cpp.get_supported_arguments (warning_c_args), language: 'cpp')
add_project_link_arguments (cpp.get_supported_link_arguments (warning_c_link_args), language: 'cpp')

########################
# Source               #
########################

# source tree
subdir ('src')

# example application
subdir ('example')

# tests
subdir ('tests')

########################
# Summaries            #
########################

summary ({
    'C compiler': cc.get_id (),
    'C++ compiler': cpp.get_id (),
    'debug build': get_option ('debug') ? 'yes' : 'no',
    'develop build': get_option ('develop') ? 'yes' : 'no',
    'host cpu': host_machine.cpu_family (),
    'host endian': host_machine.endian (),
    'host system': host_machine.system (),
  }, section: 'Build environment')

if build_machine.system () != host_machine.system ()

  summary ({
      'build cpu' : build_machine.cpu_family (),
      'build endian' : build_machine.endian (),
      'build system' : build_machine.system (),
    }, section: 'Build environment')
endif
