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
from itertools import chain
from pathlib import Path
from re import compile, ASCII
from sys import stdin, stdout
from typing import BinaryIO, Iterator, TextIO

class Arguments:

  def __init__ (self, c: int, C: bool, l: int, n: str) -> None:

    self._column_bytes = c
    self._capitalize_name = C
    self._length = l
    self._variable_name = n

  @property
  def capitalize_name (self):

    return self._capitalize_name

  @property
  def column_bytes (self):

    return self._column_bytes

  @property
  def variable_name (self):

    if not self._capitalize_name:

      return self._variable_name
    else:
      return self._variable_name.upper ()

escape_re = compile ('([a-zA-Z0-9_]+)', flags = ASCII)

def make_name (input: str):

  if '-' == input:

    return 'stdin'
  else:

    iter = escape_re.finditer (input)
    iter = map (lambda i: i.group (0), iter)

    return '_'.join (iter)

def phase1 (input: str, output: str, arguments: Arguments):

  if '-' == input:

    phase2 (stdin, output, arguments) # type: ignore
  else:

    with Path (input).open ('rb') as stream:
      phase2 (stream, output, arguments)

def phase2 (input: BinaryIO, output: str, arguments: Arguments):

  if '-' == output:

    phase3 (input, stdout, arguments) # type: ignore
  else:

    with Path (output).open ('wt') as stream:
      phase3 (input, stream, arguments)

def grouped (input: Iterator[tuple[bytes,int]], group_siz: int = 16):

  accumulator: list[bytes] = []
  reserved = 0

  for (chunk, got) in input:

    taken = 0

    while 0 < got - taken:

      take = min (got - taken, group_siz - reserved)
      byte = chunk [taken: taken + take]

      reserved += take
      taken += take

      accumulator.append (byte)

      if reserved == group_siz:

        reserved = 0

        yield chain (accumulator)
        accumulator.clear ()

  if reserved > 0:

    yield chain (accumulator)

def write_byte (b: int|str):

  n = b if isinstance (b, int) else ord (b)
  return f'0x{n:02x}'

def write_bytes (input: BinaryIO, output: TextIO, indent: str, arguments: Arguments):

  count = 0

  for iter in grouped (chunked (input, 1024), arguments.column_bytes):

    output.write ('\n' if 0 == count else ',\n')
    output.write (indent)

    first = True

    for piece in iter:

      count += len (piece)

      for byte in map (write_byte, piece):

        if first:

          first = False
          output.write (byte)
        else:
          output.write (', ')
          output.write (byte)

  return count

def phase3 (input: BinaryIO, output: TextIO, arguments: Arguments):

  output.write ('')

  output.write ('\n')
  output.write (f'unsigned char {arguments.variable_name}[] = {{')

  count = write_bytes (input, output, '  ', arguments)

  output.write ('\n};\n\n')

  suffix = 'len' if not arguments.capitalize_name else 'LEN'
  output.write (f'unsigned int {arguments.variable_name}_{suffix} = {count};\n')

if __name__ == '__main__':

  parser = ArgumentParser ('xxd')

  parser.add_argument ('input', default = '-', metavar = 'file', nargs = '?', type = str)
  parser.add_argument ('output', default = '-', metavar = 'output', nargs = '?', type = str)

  parser.add_argument ('-c', default = 16, metavar = 'cols', type = int)
  parser.add_argument ('-C', action = 'store_true')
  parser.add_argument ('-i', action = 'store_true')
  parser.add_argument ('-l', metavar = 'cols', type = int)
  parser.add_argument ('-n', default = None, metavar = 'name', type = str)

  args = parser.parse_args ()
  arguments = Arguments (args.c, args.C, args.l, args.n if None != args.n else make_name (args.input))

  if not args.i:
    raise Exception ('should have use -i')

  phase1 (args.input, args.output, arguments)