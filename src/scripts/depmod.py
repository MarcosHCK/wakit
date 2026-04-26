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
from typing import IO, TypedDict
import json

__all__ = [ 'depmod', 'Metafile',
                      'MetafileInput',
                      'MetafileInputImport' ]

class MetafileInputImport (TypedDict):

  kind: str
  original: str
  path: str

class MetafileInput (TypedDict):

  bytes: int
  format: str
  imports: list[MetafileInputImport]

class Metafile (TypedDict):

  inputs: dict[str, MetafileInput]

def depmod (stream: IO[bytes] | IO[str]):

  data: Metafile = json.load (fp = stream)

  if not (inputs := data.get ('inputs', None)):
    raise Exception ('invalid build meta file')

  elif not isinstance (inputs, dict):
    raise Exception ('invalid build meta file')

  return (f for f in inputs.keys ())