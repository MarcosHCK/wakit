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
from argparse import ArgumentParser
from functools import lru_cache
from introspectdbus.dbusinfo import DBusInterfaceInfo, DBusArgInfo
from jinja2 import Environment, FileSystemLoader
from pathlib import Path
from tempfile import NamedTemporaryFile
from tool import tool as introspect
from typing import Generator, Iterable, IO
import json

class TemplateManager:

  def __init__ (self, base: Path) -> None:

    self.env = Environment (loader = FileSystemLoader (base),
                            trim_blocks = True,
                            lstrip_blocks = True)

    for name in [ 'out_signature' ]:

      self.env.filters [name] = getattr (TemplateManager, f'format_{name}')

  @staticmethod
  def format_out_signature (infos: list[DBusArgInfo]):
    pass

  @lru_cache (maxsize = 128)
  def get_template (self, template_name: str):
    return self.env.get_template (template_name)

  def render (self, template_name: str, **context):
    return self.get_template (template_name).render (**context)

def emit_info (out: IO[str], info: tuple[DBusInterfaceInfo, str]):
  print (info, file = out)

def emit_infos (out: IO[str], infos: Iterable[tuple[DBusInterfaceInfo, str]]):

  path = Path (__file__).parent / 'introspectdbus'

  infos_ = list (infos)

  manager = TemplateManager (path)
  result = manager.render ('types.d.ts.jinja2', infos = infos_, has_signals = any ((not not i[0].get ('signals') for i in infos_)))

  print (result, file = out)

if __name__ == '__main__':

  parser = ArgumentParser ('apigen')

  parser.add_argument ('input', metavar = 'file', nargs = '*', type = str)

  parser.add_argument ('--bin', default = 'introspect-dbus', metavar = 'bin', type = str)
  parser.add_argument ('-o', '--output', default = '-', metavar = 'file', type = str)

  exes: list[str]

  args = parser.parse_args ()
  exes = args.input

  def list_infos () -> Generator[tuple[DBusInterfaceInfo, str]]:

    with NamedTemporaryFile ('r+t') as tmpfile:

      introspect (args.bin, [ '--output', tmpfile.name, *exes ])

      for line, source in zip (tmpfile, exes):

        yield (json.loads (line), source)

  if '-' == args.output:

    from sys import stdout
    emit_infos (stdout, list_infos ())
  else:

    with Path (args.output).open ('wt') as stream:
      emit_infos (stream, list_infos ())