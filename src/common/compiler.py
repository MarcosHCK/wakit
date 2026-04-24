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
from chunked import chunked
from pathlib import Path
from subprocess import Popen, PIPE
from typing import BinaryIO

__all__ = [ 'esbuild', 'xxd' ]

def esbuild (bin: str, args: list[str]):

  executable = (bins := bin.split (' ')) [0]
  subprocess = Popen ([ *bins, *args ], executable = executable, stderr = PIPE)

  if 0 != (code := subprocess.wait ()):

    from sys import stderr
    assert subprocess.stderr

    for (chunk, _) in chunked (subprocess.stderr):
      stderr.write (chunk.decode ('utf-8'))

    raise Exception (f'bad return value from esbuild ({code})')

def removing_trailing_newline (input: BinaryIO):

  last: None | tuple[bytes,int] = None

  for tuple_ in chunked (input):

    if not not last:
      yield last

    last = tuple_

  if not not (tuple_ := last):

    eat = 0

    if b'\n' == tuple_[0] [-1]:

      eat = 1

      if b'\r' == tuple_[0] [-2]:

        eat = 2

      tuple_ = (tuple_[0] [:-eat], tuple_[1] - eat)

    yield tuple_

def xxd (bin: str, input: Path, args: list[str], extra_data: bytes | None = None):

  with Path (input).open ('rb') as stream:

    return xxd_phase2 (bin, stream, args, extra_data)

def xxd_phase2 (bin: str, input: BinaryIO, args: list[str], extra_data: bytes | None = None):

  executable = (bins := bin.split (' ')) [0]
  subprocess = Popen ([ *bins, *args ], executable = executable, stdin = PIPE)

  assert subprocess.stdin

  for (chunk, _) in removing_trailing_newline (input):
    subprocess.stdin.write (chunk)

  if not not extra_data:
    subprocess.stdin.write (extra_data)
  
  subprocess.communicate (b'\0')

  if 0 != (code := subprocess.wait ()):
    raise Exception (f'bad return value from xxd ({code})')