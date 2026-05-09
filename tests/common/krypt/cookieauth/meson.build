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

c_args = [ '-DG_LOG_DOMAIN="Wakit.Tests"', '-DG_LOG_USE_STRUCTURED=1',
           '-DBUILD_DIR="@0@"'.format (meson.current_build_dir ()),
           '-DSOURCE_DIR="@0@"'.format (meson.current_source_dir ()), ]

testpath = meson.current_source_dir ().replace (basepath + '/', '')

test ((testpath + '/client').replace ('/', '.'),
      executable ('client',
            c_args: c_args +
                    [ '-DTESTPATHROOT="@0@"'.format (testpathroot / testpath / 'client') ],
            cpp_args: c_args +
                      [ '-DTESTPATHROOT="@0@"'.format (testpathroot / testpath / 'client') ],
            cpp_pch: 'pch/pch.h',
            build_by_default: false,
            dependencies: [ config_dep, __common_dep, __common_krypt_dep, __testing_dep ],
            sources: [ 'client.cc', 'providers.h' ]),
      env: [ 'G_TEST_BUILDDIR=@0@'.format (meson.current_build_dir ()),
             'G_TEST_SRCDIR=@0@'.format (meson.current_source_dir ()) ], )

test ((testpath + '/integration').replace ('/', '.'),
      executable ('integration',
            c_args: c_args +
                    [ '-DTESTPATHROOT="@0@"'.format (testpathroot / testpath / 'integration') ],
            cpp_args: c_args +
                      [ '-DTESTPATHROOT="@0@"'.format (testpathroot / testpath / 'integration') ],
            cpp_pch: 'pch/pch.h',
            build_by_default: false,
            dependencies: [ config_dep, __common_dep, __common_krypt_dep, __testing_dep ],
            sources: [ 'integration.cc', 'providers.h' ]),
      env: [ 'G_TEST_BUILDDIR=@0@'.format (meson.current_build_dir ()),
             'G_TEST_SRCDIR=@0@'.format (meson.current_source_dir ()) ], )

test ((testpath + '/server').replace ('/', '.'),
      executable ('server',
            c_args: c_args +
                    [ '-DTESTPATHROOT="@0@"'.format (testpathroot / testpath / 'server') ],
            cpp_args: c_args +
                      [ '-DTESTPATHROOT="@0@"'.format (testpathroot / testpath / 'server') ],
            cpp_pch: 'pch/pch.h',
            build_by_default: false,
            dependencies: [ config_dep, __common_dep, __common_krypt_dep, __testing_dep ],
            sources: [ 'server.cc', 'providers.h' ]),
      env: [ 'G_TEST_BUILDDIR=@0@'.format (meson.current_build_dir ()),
             'G_TEST_SRCDIR=@0@'.format (meson.current_source_dir ()) ], )