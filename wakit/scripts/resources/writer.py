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
from pathlib import Path, PurePath
from resources.entities import File
from types import TracebackType
from typing import IO, Iterable
from writer import Writer as _Writer

__all__ = [ 'Writer' ]

class Writer (_Writer[str]):

  def __init__ (self, output: Path | IO[str]):

    super (Writer, self).__init__ (output, 't')

  def __enter__ (self):

    super (Writer, self).__enter__ ()

    self.write ('<?xml version="1.0" encoding="UTF-8"?>\n')
    self.write ('<!DOCTYPE gresources PUBLIC "-//GNOME//DTD GResource Specification 1.0//EN" "/usr/share/glib-2.0/dtds/gresource.dtd">\n')
    self.write ('<gresources>\n')

    return self

  def __exit__ (self, exc_type: type[BaseException] | None, exc_val: BaseException | None, exc_tb: TracebackType | None) -> None:

    if not not (stream := self.stream):
      stream.write ('</gresources>\n')

    return super ().__exit__ (exc_type, exc_val, exc_tb)

  def add_file (self, basedir: Path, file: str | File):

    self.write (f'\t\t<file')

    if not isinstance (file, File):

      path = Path (file)
    else:
      path = Path (file.path)

      if not not file.alias:
        self.write (f' alias="{file.alias}"')

      if not not file.compressed:

        self.write (f' compressed="true"')
      else:
        self.write (f' compressed="false"')

      if not not file.preprocess:
        self.write (f' preprocess="{file.preprocess}"')

    if path.is_absolute ():
      raise Exception ('files must be an relative path')

    self.write (f'>{path.resolve ().relative_to (basedir)}</file>\n')

  def add_resource (self, base: PurePath, basedir: Path, files: Iterable[str | File]):

    if not base.is_absolute ():
      raise Exception ('resources base must be an absolute path')

    self.write (f'\t<gresource prefix="{base}">\n')

    for file in files:
      self.add_file (basedir, file)

    self.write (f'\t</gresource>\n')