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
from fileutils import AtomicWrite
from pathlib import Path
from typing import Callable, Generator, Iterable, IO
from subprocess import Popen, PIPE

def enumerate_vapis (dir: Path) -> Generator[Path]:

  for child in dir.iterdir ():

    if child.is_dir ():
      yield from enumerate_vapis (child)

    if child.name.endswith ('vapi'):
      yield child.resolve ()

def iter_bracket_pairs (chunk: str, last: int = 0):

  while True:

    if -1 == (start := chunk.find ('[', last)):
      return start

    if -1 == (stop := chunk.find (']', 1 + last)):
      return start

    yield start, (last := 1 + stop) - 1

def patch_attribute (chunks: Iterable[str], transform: Callable[[str], str]):

  acc = None

  for chunk in chunks:

    if not not acc:
      chunk = acc + chunk
      acc = None

    last = 0

    try:

      pairs = iter (iter_bracket_pairs (chunk))

      while True:

        start, stop = next (pairs)

        yield chunk [last:start]
        yield transform (chunk [1 + start:stop])
        last = 1 + stop

    except StopIteration as stope:

      if -1 == (start := stope.value):

        yield chunk [last:]
      else:

        acc = chunk [start:]
        yield chunk [last:start]

def patch_vapi (file: Path, transform: Callable[[str], str], chunk_siz: int = 1024):

  with file.open ('rt') as input, AtomicWrite (file, 'wt', leaveIfUnmodified = True) as output:
    patch_vapi_ (input, output, transform, chunk_siz)

def patch_vapi_ (input: IO[str], output: IO[str], transform: Callable[[str], str], chunk_siz: int = 1024):

  for piece in patch_attribute ((chunk for chunk,_ in chunked (input, chunk_siz)), transform):
    output.write (piece)

def transform (value: str, proc: Popen[str]):

  proc.stdin.write (value) # type: ignore
  proc.stdin.write ('\n') # type: ignore
  proc.stdin.flush () # type: ignore

  line: str = proc.stdout.readline () [:-1] # type: ignore

  return f'[{line}]'

if __name__ == '__main__':

  parser = ArgumentParser ('fixvapis')

  parser.add_argument ('basedir', default = '.', metavar = 'DIRECTORY', nargs = '?', type = str)

  parser.add_argument ('--bin', default = None, metavar = 'BINARY', type = str)
  parser.add_argument ('-b', default = None, metavar = 'DIRECTORY', type = str)

  args = parser.parse_args ()

  if not (basedir := Path (args.basedir)).is_dir ():
    raise Exception ('basedir must a local directory')

  base = Path (args.b or basedir).resolve ()
  proc = Popen ([ args.bin ], executable = args.bin, stdin = PIPE, stdout = PIPE, text = True)

  for vapi in enumerate_vapis (basedir):

    header = str (vapi.relative_to (base))
    header = f"$\"{header [:-len ('.vapi')]}.h\""

    proc.stdin.write (header) # type: ignore
    proc.stdin.write ('\n') # type: ignore
    proc.stdin.flush () # type: ignore

    patch_vapi (vapi, lambda v: transform (v, proc))