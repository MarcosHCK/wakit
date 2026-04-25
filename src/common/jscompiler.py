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
from compiler import esbuild, xxd
from pathlib import Path
from xxd import make_name

if __name__ == '__main__':

  parser = ArgumentParser ('jscompiler')

  parser.add_argument ('input', default = '-', metavar = 'file', nargs = '?', type = str)
  parser.add_argument ('output', default = '-', metavar = 'output', nargs = '?', type = str)

  parser.add_argument ('-b', default = '.', metavar = 'dir', type = str)
  parser.add_argument ('--esbuild', default = 'esbuild', metavar = 'bin', type = str)
  parser.add_argument ('-n', default = None, metavar = 'dir', type = str)
  parser.add_argument ('--xxd', default = 'xxd', metavar = 'bin', type = str)

  args = parser.parse_args ()
  base = Path (args.b)

  input_file = Path (args.input)
  input_vec = input_file.name.split ('.')

  match (ext := input_vec [-1]):

    case 'css':
      esbuild_args = [ ]
      extra_data = None
      final_ext = '.min.css'
  
    case 'js' | 'ts':
      esbuild_args = [ '--bundle', '--format=iife', '--global-name=__module__' ]
      extra_data = b'__module__'
      final_ext = '.min.js'

    case _:
      raise Exception (f'unknown file type {ext}')

  if 2 > len (input_vec):

    module_file = base / (input_vec [0] + final_ext)
  else:
    module_file = base / ('.'.join (input_vec [:-1]) + final_ext)

  esbuild (args.esbuild, [ '--minify', *esbuild_args,
                           f'--outfile={str (module_file.absolute ())}', str (input_file.absolute ()) ])

  variable_name = args.n if None != args.n else make_name (args.input)

  xxd (args.xxd, module_file.absolute (), [ '-i', '-n', variable_name, '-' ] + ([ ] if '-' == args.output else
                                                                                [ args.output ]),
       extra_data)