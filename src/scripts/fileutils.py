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
from os import fdopen, fsync
from pathlib import Path
from tempfile import mkstemp
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

@overload
def AtomicWrite (file: str | Path, mode: _ABinary | _RBinary | _WBinary | _XBinary, encoding: str | None = 'utf-8') -> IO[bytes]:
  ...

@overload
def AtomicWrite (file: str | Path, mode: _AText | _RText | _WText | _XText, encoding: str | None = 'utf-8') -> IO[str]:
  ...

@contextmanager
def AtomicWrite (file: str | Path, mode: str = 'w', encoding: str | None = 'utf-8'):

  file = Path (file)
  (dirname := file.parent).mkdir (exist_ok = True, parents = True)

  name = None
  stream = None

  try:

    binary = 'b' in mode
    fd, name = mkstemp (dir = dirname, suffix = '.tmp', text = not binary)

    if binary:

      stream = fdopen (fd, mode)
    else:
      stream = fdopen (fd, mode, encoding = encoding)

    yield stream

    stream.flush ()
    fsync (fd)

    (name := Path (name)).replace (file)
  except Exception:

    if not not stream:
      stream.close ()

    if not not name and (name := Path (name)).exists ():
      name.unlink ()

    raise
  finally:

    if not not stream:
      stream.close ()