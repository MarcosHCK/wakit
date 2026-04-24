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
from chunked import chunked
from pathlib import Path
from subprocess import Popen, PIPE
from typing import TextIO
from xxd import make_name

def esbuild (bin: str, args: list[str]):

  executable = (bins := bin.split (' ')) [0]
  subprocess = Popen ([ *bins, *args ], executable = executable, stderr = PIPE)

  if 0 != (code := subprocess.wait ()):

    from sys import stderr
    assert subprocess.stderr

    for (chunk, _) in chunked (subprocess.stderr):
      stderr.write (chunk.decode ('utf-8'))

    raise Exception (f'bad return value from esbuild ({code})')

def removing_trailing_newline (input: TextIO):

  last: None | tuple[str,int] = None

  for tuple_ in chunked (input):

    if not not last:
      yield last

    last = tuple_

  if not not (tuple_ := last):

    eat = 0

    if '\n' == tuple_[0] [-1]:

      eat = 1

      if '\r' == tuple_[0] [-2]:

        eat = 2

      tuple_ = (tuple_[0] [:-eat], tuple_[1] - eat)

    yield tuple_

def xxd (bin: str, input: Path, args: list[str]):

  with Path (input).open ('rt') as stream:

    return xxd_phase2 (bin, stream, stream, args)

def xxd_phase2 (bin: str, input: TextIO, output: TextIO, args: list[str]):

  executable = (bins := bin.split (' ')) [0]
  subprocess = Popen ([ *bins, *args ], executable = executable, stdin = PIPE, text = True)

  assert subprocess.stdin

  for (chunk, _) in removing_trailing_newline (input):

    subprocess.stdin.write (chunk)

  subprocess.communicate ('__module__')

  if 0 != (code := subprocess.wait ()):

    raise Exception (f'bad return value from xxd ({code})')

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

  if 2 > len (input_vec):

    module_file = base / (input_vec [0] + '.min.js')
    header_file = base / (input_vec [0] + '.hex.c')
  else:
    module_file = base / ('.'.join (input_vec [:-1]) + '.min.js')
    header_file = base / ('.'.join (input_vec [:-1]) + '.hex.c')

  esbuild (args.esbuild, [ '--minify', '--format=iife', '--global-name=__module__',
                           f'--outfile={str (module_file.absolute ())}', str (input_file.absolute ()) ])

  variable_name = args.n if None != args.n else make_name (args.input)

  xxd (args.xxd, module_file.absolute (), [ '-i', '-n', variable_name, '-' ] + ([ ] if '-' == args.output else
                                                                                [ args.output ]))