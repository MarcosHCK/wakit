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
from argparse import Action, ArgumentError, ArgumentParser, Namespace
from logging import getLogger
from pathlib import Path
from resources.entities import Flag, Input, InputFile, Resources
from typing import Any, Sequence

logger = getLogger (__file__)

__all__ = [ 'parse_args' ]

class ArgumentAccumulator:

  def __init__ (self) -> None:

    super (ArgumentAccumulator, self).__init__ ()

    self.base: Path | None = None
    self.files: set[InputFile] = set ()
    self.flags: set[Flag] = set ()
    self.inputs: list[Input] = [ ]

  def add_file (self, file: Path):

    if not self.base:
      raise ArgumentError (None, 'a file came before a -s (section start flag)')

    flags = set (self.flags)

    self.flags.clear ()
    self.files.add (InputFile (file, flags))

  def add_flag (self, value: str):

    if not self.base:
      raise ArgumentError (None, 'an -o flag came before a -s (section start flag)')

    self.flags.add (Flag.parse (value))

  def complete (self):

    self.push_section ()
    self.base = None

    self.files.clear ()
    self.flags.clear ()

    result = Resources.parse_inputs (self.inputs)
    result = Resources (result)

    self.inputs.clear ()
    return result

  def open_section (self, path: Path):

    self.push_section ()
    self.base = path

  def push_section (self):
  
    if not self.base or 0 == len (self.files):
      return

    if len (self.flags) > 0:
      logger.warning ('superfluos -o flags')

    self.flags.clear ()
    self.inputs.append (Input (self.base, set (self.files)))

    self.files.clear ()

class FileAction (Action):

  def __init__ (self, *args, **kwargs) -> None:

    accumulator: ArgumentAccumulator = kwargs.pop ('accumulator')

    super (FileAction, self).__init__ (nargs = 1, type = str, *args, **kwargs)
    self.accumulator = accumulator

  def __call__ (self, parser: ArgumentParser, namespace: Namespace, values: Sequence[Any] | None, option_string: str | None = None):

    assert values
    self.accumulator.add_file (Path (values [0]))

class FlagAction (Action):

  def __init__ (self, *args, **kwargs) -> None:

    accumulator: ArgumentAccumulator = kwargs.pop ('accumulator')

    super (FlagAction, self).__init__ (nargs = 1, type = str, *args, **kwargs)
    self.accumulator = accumulator

  def __call__ (self, parser: ArgumentParser, namespace: Namespace, values: Sequence[Any] | None, option_string: str | None = None):

    assert values
    self.accumulator.add_flag (values [0])

class SectionAction (Action):

  def __init__ (self, *args, **kwargs) -> None:

    accumulator: ArgumentAccumulator = kwargs.pop ('accumulator')

    super (SectionAction, self).__init__ (nargs = 1, type = str, *args, **kwargs)
    self.accumulator = accumulator

  def __call__ (self, parser: ArgumentParser, namespace: Namespace, values: Sequence[str] | None, option_string: str | None = None):

    assert values
    self.accumulator.open_section (Path (values [0]))

def parse_args (parser: ArgumentParser):

  collector = ArgumentParser (parser.prog)

  accumulator = ArgumentAccumulator ()

  collector.add_argument ('-f', action = FlagAction, accumulator = accumulator, metavar = 'name=value')
  collector.add_argument ('-s', action = SectionAction, accumulator = accumulator, metavar = '<directory> [-o ...]+ <files> [<files>, ...]')
  collector.add_argument ('input', action = FileAction, accumulator = accumulator, metavar = '<files> [<files>, ...]')

  namespace, extra = parser.parse_known_args ()

  while len (extra) > 0:

    _, left = collector.parse_known_args (extra)
    extra = left

  return (namespace, accumulator.complete ())