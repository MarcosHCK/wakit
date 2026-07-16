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
from glob import glob
from pathlib import Path, PurePath
from typing import Generator, Iterable, Literal, NamedTuple
from typing import overload

__all__ = [ 'Flag', 'Input', 'InputFile', 'Resources' ]

class Flag:

  name: str
  value: bool | str

  @overload
  def __init__ (self, name: Literal['alias'], value: str):
    ...

  @overload
  def __init__ (self, name: Literal['compressed'], value: bool):
    ...

  @overload
  def __init__ (self, name: Literal['preprocess'], value: str):
    ...

  def __init__ (self, name: str, value: bool | str) -> None:

    super (Flag, self).__init__ ()

    self.name = name
    self.value = value

  @staticmethod
  def parse (value: str) -> 'Flag':

    if 2 != len (segments := value.split ('=')):
      raise Exception (f"invalid flag element '{value}'")

    match (name := segments [0]):

      case 'alias': return Flag (name, str (segments [1]))
      case 'compressed': return Flag (name, Flag.parse_boolean (segments [1]))
      case 'preprocess': return Flag (name, str (segments [1]))
      case _: raise Exception (f"invalid flag element '{value}'")

  @staticmethod
  def parse_boolean (value: str) -> bool:

    match value:

      case '1' | 'true' | 'True': return True
      case '0' | 'false' | 'False': return False

    raise Exception (f"invalid flag element value '{value}'")

class File (NamedTuple):

  alias: str | None
  compressed: bool
  preprocess: str | None
  path: PurePath

  def __eq__ (self, value):

    if not isinstance (value, File):
      return False

    return self.path == value.path

  def __hash__ (self):
    return hash (self.path)

class Input:

  def __init__ (self, base: Path, files: set['InputFile']) -> None:

    super (Input, self).__init__ ()

    self.base = base
    self.files = files

  @staticmethod
  def parse (value: str):

    if 2 > len (paths := value.split (',')):
      raise Exception (f"invalid input element '{input}'")

    base = Path ('/' if '' == (base := paths [0]) else base)
    files = set (( InputFile.parse (f) for f in paths [1:] ))

    return Input (base, files)

class InputFile:

  def __init__ (self, file: Path, options: set[Flag]) -> None:

    super (InputFile, self).__init__ ()

    self.file = file
    self.options = options

  @staticmethod
  def parse (value: str) -> 'InputFile':

    match len (segments := value.split (':')):

      case 1:
        return InputFile (Path (segments [0]), set ())

      case 2:
        flags = ( Flag.parse (o) for o in segments [0].split (',') )
        return InputFile (Path (segments [1]), set (flags))

    raise Exception (f"invalid file element '{input}'")

def iterdir (path: Path) -> Generator[Path]:

  if path.is_file ():

    yield path
  else:

    for child in path.iterdir ():
      yield from iterdir (child)

class Resources (dict[Path,set[File]]):

  def __init__ (self, items: dict[Path,set[File]]
                           | Iterable[tuple[Path, set[File]]]):

    super (Resources, self).__init__ (items)

  @staticmethod
  def parse (input: list[str]):

    inputs = (Input.parse (i) for i in input)
    dict = Resources.parse_inputs (inputs)

    return Resources (dict)

  @staticmethod
  def parse_input (input: Input):

    files = input.files
    files = set ((f for g in files for f in Resources.parse_input_file (g)))

    return (input.base, files)

  @staticmethod
  def parse_inputs (inputs: Iterable[Input]):

    acc: dict[Path, set[File]] = {}

    for base, files in (Resources.parse_input (i) for i in inputs):

      if not not (r := acc.get (base)):

        r.update (files)
      else:
        acc [base] = set (files)

    return acc

  @staticmethod
  def parse_input_file (input: InputFile):

    alias: str | None = None
    compressed: bool = False
    preprocess: str | None = None

    for option in input.options:

      match option.name:

        case 'alias': alias = option.value # type: ignore
        case 'compressed': compressed = option.value # type: ignore
        case 'preprocess': preprocess = option.value # type: ignore

    for file in (Path (p) for p in glob (str (input.file))):

      if not file.is_file ():
        raise Exception (f"invalid file found '{file}'")

      yield File (alias, compressed, preprocess, file)

