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
from argparse import Namespace
from chunked import chunked
from codecs import escape_decode
from grouped import grouped
from itertools import chain
from pathlib import Path
from re import compile, ASCII
from tool import tool
from typing import Iterable

escape_re = compile ('([a-zA-Z0-9_]+)', flags = ASCII)

def dump (input: Iterable[bytes], name: str, cols: int):

  yield f'unsigned char {name}[] = {{'

  count = yield from dump_bytes (input, cols)

  yield '\n};\n\n'
  yield f'unsigned int {name}_len = {count};\n'

def dump_bytes (input: Iterable[bytes], cols: int):

  count = 0

  for group in grouped (input, cols):

    yield '\n\t'

    for piece in group:

      count += len (piece)

      for piece in (f'0x{b:02x}' for b in piece):

        yield piece
        yield ', '

  return count

def make_name (input: str):

  if '-' == input:

    return 'stdin'
  else:

    iter = escape_re.finditer (input)
    iter = map (lambda i: i.group (0), iter)

    return '_'.join (iter)

def parse_extra (extra: str | None = None) -> list[bytes]:

  if not extra:
    return []

  value, _ = escape_decode (extra)

  if isinstance (value, bytes):

    return [ value ]
  else:
    return [ str (value).encode () ]

def write (input: Iterable[bytes], output: str, args: Namespace):

  extra = parse_extra (args.extra)
  name = args.n if None != args.n else make_name (args.input)

  if not args.bin:

    write_not_xxd (chain (input, extra), output, name, args.c)
  else:
    write_yes_xxd (chain (input, extra), output, name, args.c)

def write_not_xxd (input: Iterable[bytes], output: str, name: str, cols: int):

  pieces = dump (input, name, cols)

  if '-' == output:

    from sys import stdout
    stdout.writelines (pieces)
  else:

    with Path (output).open ('wt') as stream:
      stream.writelines (pieces)

def write_yes_xxd (input: Iterable[bytes], output: str, name: str, cols: int):

  tool (args.bin, [ '-i', '-c', str (cols), '-n', name, '-', output ], input)

if __name__ == '__main__':

  parser = ArgumentParser ('xxd')

  parser.add_argument ('input', default = '-', metavar = 'file', nargs = '?', type = str)
  parser.add_argument ('output', default = '-', metavar = 'output', nargs = '?', type = str)

  parser.add_argument ('-c', default = 16, metavar = 'cols', type = int)
  parser.add_argument ('-n', default = None, metavar = 'name', type = str)

  parser.add_argument ('--bin', default = None, metavar = 'bin', type = str)
  parser.add_argument ('--extra', default = None, metavar = 'bytes', type = str)

  args = parser.parse_args ()

  if '-' == args.input:

    from sys import stdin
    stream = (b.encode () for b,_ in chunked (stdin))

    write (stream, args.output, args)
  else:

    with Path (args.input).open ('rb') as stream:

      write ((b for b,_ in chunked (stream)), args.output, args)