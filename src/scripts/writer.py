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
from pathlib import Path
from types import TracebackType
from typing import overload
from typing import Literal, Generic, IO, TypeVar

T = TypeVar ('T', bytes, str)

class Writer (Generic [T]):

  @overload
  def __init__ (self: 'Writer[bytes]', output: Path | IO[bytes], mode: Literal['b']):
    ...

  @overload
  def __init__ (self: 'Writer[str]', output: Path | IO[str], mode: Literal['t']):
    ...

  def __init__ (self, output: Path | IO[bytes] | IO[str], mode: Literal['b'] | Literal['t']):

    self.output = None if not isinstance (output, Path) else output
    self.mode = mode
    self.stream: IO[T] | None = None if isinstance (output, Path) else output # type: ignore

  def __enter__ (self):

    if not self.stream:

      assert self.output
      self.stream = self.output.open ('w' + self.mode)
      self.stream.__enter__ ()

    return self

  def __exit__ (self, exc_type: type[BaseException] | None,
                      exc_val: BaseException | None,
                      exc_tb: TracebackType | None) -> None:

    self.flush ()

    if not not self.output:

      assert self.stream
      self.stream.__exit__ (exc_type, exc_val, exc_tb)

  def flush (self):

    if not not (stream := self.stream):

      stream.flush ()
    else:
      raise Exception ("broken stream")

  def write (self, text: T):

    if not not (stream := self.stream):

      stream.write (text)
    else:
      raise Exception ("broken stream")