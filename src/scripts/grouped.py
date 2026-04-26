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
from itertools import chain
from typing import overload
from typing import Any, Generator, Iterable, Sequence

@overload
def grouped (input: Iterable[bytes], group_siz: int = 16) -> Generator[Sequence[bytes], Any, None]:
  ...

@overload
def grouped (input: Iterable[str], group_siz: int = 16) -> Generator[Sequence[str], Any, None]:
  ...

def grouped (input: Iterable[bytes | str], group_siz: int = 16) -> Generator[Sequence[bytes | str], Any, None]:

  accumulator: list[bytes | str] = []
  reserved = 0

  for chunk in input:

    taken = 0

    while 0 < (got := len (chunk)) - taken:

      take = min (got - taken, group_siz - reserved)
      byte = chunk [taken: taken + take]

      reserved += take
      taken += take

      accumulator.append (byte)

      if reserved == group_siz:

        reserved = 0

        yield list (chain (accumulator))
        accumulator.clear ()

  if reserved > 0:

    yield list (chain (accumulator))