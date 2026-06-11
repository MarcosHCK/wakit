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
from argparse import ArgumentParser
from tempfile import NamedTemporaryFile
from tool import tool as apigen, tool as introspect

if __name__ == '__main__':

  parser = ArgumentParser ('apigen')

  parser.add_argument ('input', metavar = 'file', nargs = '*', type = str)

  parser.add_argument ('--apigen-bin', default = 'apigen-dbus', metavar = 'bin', type = str)
  parser.add_argument ('--introspect-bin', default = 'introspect-dbus', metavar = 'bin', type = str)
  parser.add_argument ('--name', default = None, metavar = 'bin', type = str)
  parser.add_argument ('--type-name', default = None, metavar = 'bin', type = str)
  parser.add_argument ('-o', '--output', default = '-', metavar = 'file', type = str)

  args = parser.parse_args () 

  with NamedTemporaryFile ('r+t') as tmpfile:

    introspect (args.introspect_bin, [ '--output', tmpfile.name, *args.input ])

    apigen_args = [ tmpfile.name, args.output ]

    if not not (name := args.name):
      apigen_args.extend ([ '--name', name ])

    if not not (type_name := args.type_name):
      apigen_args.extend ([ '--type-name', type_name ])

    apigen (args.apigen_bin, apigen_args)