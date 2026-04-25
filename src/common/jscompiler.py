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
from depfile import Depfile
from depmod import depmod
from pathlib import Path
from xxd import make_name

if __name__ == '__main__':

  parser = ArgumentParser ('jscompiler')

  parser.add_argument ('input', default = '-', metavar = 'file', nargs = '?', type = str)
  parser.add_argument ('output', default = '-', metavar = 'output', nargs = '?', type = str)

  parser.add_argument ('-b', default = '.', metavar = 'dir', type = str)
  parser.add_argument ('--dep', default = None, metavar = 'file', type = str)
  parser.add_argument ('--esbuild', default = 'esbuild', metavar = 'bin', type = str)
  parser.add_argument ('-n', default = None, metavar = 'dir', type = str)
  parser.add_argument ('--tmp', default = None, metavar = 'dir', type = str)
  parser.add_argument ('--xxd', default = 'xxd', metavar = 'bin', type = str)

  args = parser.parse_args ()

  base = Path (args.b)
  priv = base if not (tmp := args.tmp) else Path (tmp)

  input_file = Path (args.input)
  input_vec = (name := input_file.name).split ('.')

  match (ext := input_vec [-1]):

    case 'css':
      esbuild_args = [ ]
      extra_data = None
  
    case 'js' | 'ts':
      esbuild_args = [ '--bundle', '--format=iife', '--global-name=__module__' ]
      extra_data = b'__module__'

    case _:
      raise Exception (f'unknown file type {ext}')

  meta_file = priv / f'{name}.meta.json'
  module_file = priv / f'{name}.min.js'
  output_file = Path (args.output)

  if not not args.dep:

    esbuild_args.append (f'--metafile={meta_file}')

  esbuild (args.esbuild, [ '--minify', *esbuild_args,
                           f'--outfile={str (module_file.absolute ())}', str (input_file.absolute ()) ])

  if not not (file := args.dep):

    with Depfile (Path (file)) as depfile:

      # depfile.add_step (output_file, [ module_file ])
      # depfile.add_step (module_file, (Path (f) for f in depmod (meta_file)))
      depfile.add_step (output_file, (Path (f) for f in depmod (meta_file)))

  variable_name = args.n if None != args.n else make_name (args.input)

  xxd (args.xxd, module_file.absolute (), [ '-i', '-n', variable_name, '-' ] + ([ ] if '-' == args.output else
                                                                                [ args.output ]),
       extra_data)