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
from depfile.writer import Writer as DepWriter
from depmod import depmod
from tool import tool as esbuild
from pathlib import Path
from tempfile import NamedTemporaryFile

if __name__ == '__main__':

  parser = ArgumentParser ('esbuild')

  parser.add_argument ('input', default = '-', metavar = 'file', nargs = '?', type = str)
  parser.add_argument ('output', default = '-', metavar = 'output', nargs = '?', type = str)

  parser.add_argument ('--bin', default = 'esbuild', metavar = 'bin', type = str)
  parser.add_argument ('--dep', default = None, metavar = 'file', type = str)

  args = parser.parse_args ()

  dep_file = None if not args.dep else Path (args.dep)

  input_file = Path (args.input)
  output_file = Path (args.output)

  if not args.dep:

    esbuild (args.bin, [ '--bundle', '--format=iife', '--global-name=__module__', '--minify',
                         f'--outfile={str (output_file.absolute ())}', str (input_file.absolute ()) ])

  else:

    with NamedTemporaryFile ('r+t') as tmpfile:

      esbuild (args.bin, [ '--bundle', '--format=iife', '--global-name=__module__', '--minify',
                           f'--metafile={tmpfile.name}',
                           f'--outfile={str (output_file.absolute ())}', str (input_file.absolute ()) ])

      with DepWriter (Path (args.dep)) as dep:

        dep.add_step (output_file, (Path (f) for f in depmod (tmpfile.file)))