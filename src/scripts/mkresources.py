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
from depfile.writer import Writer as DepWriter
from pathlib import Path
from resources.argparse import parse_args
from resources.writer import Writer as ResourcesWriter
from tempfile import NamedTemporaryFile
from tool import tool as compiler

if __name__ == '__main__':

  parser = ArgumentParser ('mkresources')

  parser.add_argument ('--bin', default = 'glib-compile-resources', metavar = 'bin', type = str)

  parser.add_argument ('-b', '--basedir', default = '.', metavar = 'dir', type = str)

  parser.add_argument ('--depfile', default = None, metavar = 'file', type = str)
  parser.add_argument ('--header', default = None, metavar = 'file', type = str)
  parser.add_argument ('--source', default = None, metavar = 'file', type = str)

  parser.add_argument ('--internal', action = 'store_true')
  parser.add_argument ('--manual', action = 'store_true')
  parser.add_argument ('--name', default = None, metavar = 'name', type = str)

  (args, resources) = parse_args (parser)

  basedir = Path (args.basedir)

  if 0 == sum (( int (not not b) for b in [ args.header, args.source ] )):
    raise Exception ('at least one of --header or --source should be specified')

  if not not args.depfile:

    with DepWriter (Path (args.depfile)) as writer:

      if not not (target := args.header):
        writer.add_step (Path (target), (Path (f.path) for s in resources.values () for f in s))

      if not not (target := args.source):
        writer.add_step (Path (target), (Path (f.path) for s in resources.values () for f in s))

  with NamedTemporaryFile ('w+t', suffix = '.gresources.xml') as tempfile:

    with ResourcesWriter (tempfile.file) as writer:

      for (base, files) in resources.items ():
        writer.add_resource (base, basedir, files)

    tempfile.file.flush ()

    options = [ '--sourcedir', str (basedir.absolute ()) ]

    for name, option, store in [ ('internal', '--internal', False), ('manual', '--manual-register', False),
                                 ('name', '--c-name', True) ]:

      if not not (value := getattr (args, name)):

          options.append (option if not store else f'{option}={value}')

    if not not (target := args.header):
      compiler (args.bin, [ '--generate-header', f'--target={target}', *options, tempfile.name ])

    if not not (target := args.source):
      compiler (args.bin, [ '--generate-source', f'--target={target}', *options, tempfile.name ])