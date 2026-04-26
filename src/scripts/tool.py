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
from subprocess import Popen, PIPE
from typing import Iterable

__all__ = [ 'tool' ]

def tool (bin: str, args: list[str], input: Iterable[bytes] | None = None):

  executable = (bins := bin.split (' ')) [0]
  subprocess = Popen ([ *bins, *args ], executable = executable, stderr = PIPE,
                                                                 stdin = None if not input else PIPE)

  if not not input:

    assert (stdin := subprocess.stdin)

    for piece in input:
      stdin.write (piece)

    subprocess.communicate ()

  if 0 != (code := subprocess.wait ()):

    from sys import stderr
    assert subprocess.stderr

    for (chunk, _) in chunked (subprocess.stderr):
      stderr.write (chunk.decode ('utf-8'))

    raise Exception (f'bad return value from {executable} ({code})')