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
from contextlib import contextmanager
from os import fsync
from pathlib import Path
from tempfile import NamedTemporaryFile
from typing import overload, IO, Literal

_ABinary = Literal['ab', 'a+b']
_RBinary = Literal['rb', 'r+b']
_WBinary = Literal['wb', 'w+b']
_XBinary = Literal['xb', 'x+b']
_AText = Literal['a', 'a+', 'at', 'a+t']
_RText = Literal['r', 'r+', 'rt', 'r+t']
_WText = Literal['w', 'w+', 'wt', 'w+t']
_XText = Literal['x', 'x+', 'xt', 'x+t']

_AMode = _AText | _ABinary
_RMode = _RText | _RBinary
_WMode = _WText | _WBinary
_XMode = _XText | _XBinary

def compare (file1: str | Path, file2: str | Path):

  with Path (file1).open ('rb') as stream1, Path (file2).open ('rb') as stream2:

    while True:

      chunk1 = stream1.read (65536)
      chunk2 = stream2.read (65536)

      if chunk1 != chunk2:
        return False

      if not chunk1:
        return True

@overload
def AtomicWrite (file: str | Path, mode: _ABinary | _RBinary | _WBinary | _XBinary, encoding: str | None = 'utf-8', leaveIfUnmodified: bool = False) -> IO[bytes]:
  ...

@overload
def AtomicWrite (file: str | Path, mode: _AText | _RText | _WText | _XText, encoding: str | None = 'utf-8', leaveIfUnmodified: bool = False) -> IO[str]:
  ...

@contextmanager
def AtomicWrite (file: str | Path, mode: str = 'w', encoding: str | None = 'utf-8', leaveIfUnmodified: bool = False):

  file = Path (file)
  (dirname := file.parent).mkdir (exist_ok = True, parents = True)

  tmpfile = None

  try:

    tmpfile = NamedTemporaryFile (mode, delete = False, dir = dirname, encoding = encoding, suffix = '.tmp')
    yield tmpfile.file

    tmpfile.flush ()
    fsync (tmpfile.fileno ())

    if not leaveIfUnmodified or not compare (file, tmpfile.name):

      tmpfile.close ()
      Path (tmpfile.name).replace (file)
      tmpfile = None

  finally:

    if not not tmpfile:

      tmpfile.close ()
      Path (tmpfile.name).unlink ()