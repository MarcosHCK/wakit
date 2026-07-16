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
from pathlib import Path
from resources.argparse import parse_args
from resources.writer import Writer as ResourcesWriter
from tempfile import NamedTemporaryFile
from tool import tool as compiler

if __name__ == '__main__':

  parser = ArgumentParser ('mkbundle')

  parser.add_argument ('--bin', default = 'glib-compile-resources', metavar = 'bin', type = str)

  parser.add_argument ('-b', '--basedir', default = '.', metavar = 'dir', type = str)
  parser.add_argument ('-o', '--output', default = 'bundle.gresource', metavar = 'file', nargs = '?', type = str)

  (args, resources) = parse_args (parser)

  basedir = Path (args.basedir)
  output = Path (args.output)

  with NamedTemporaryFile ('w+t', suffix = '.gresources.xml') as tempfile:

    with ResourcesWriter (tempfile.file) as writer:

      for (base, files) in resources.items ():
        writer.add_resource (base, basedir, files)

    tempfile.file.flush ()

    options = [ '--sourcedir', str (basedir.absolute ()),
                '--target', str (output.absolute ()) ]

    compiler (args.bin, [ *options, tempfile.name ])