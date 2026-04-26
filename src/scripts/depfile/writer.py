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
from typing import Iterable
from writer import Writer as _Writer

__all__ = [ 'Writer' ]

class Writer (_Writer[str]):

  def __init__ (self, output: Path, base: Path | None = None) -> None:

    super (Writer, self).__init__ (output, 't')

    self.base = base if not not base else Path ('.')
    self.first = True

  def __exit__ (self, exc_type: type[BaseException] | None, exc_val: BaseException | None, exc_tb: TracebackType | None) -> None:

    if not not (stream := self.stream):
      stream.write ('\n')

    return super ().__exit__ (exc_type, exc_val, exc_tb)

  def add_step (self, result: Path, inputs: Iterable[Path]):

    if not self.first:

      self.write ('\n\n')
    else:
      self.first = False

    self.write (str (result.relative_to (self.base)))
    self.write (':')

    for file in (f.relative_to (self.base) for f in inputs):

      self.write (' ')
      self.write (str (file))