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
from typing import TypedDict

class DBusAnnotationInfo (TypedDict):

  annotations: list['DBusAnnotationInfo']

  key: str
  value: str

class DBusArgInfo (TypedDict):

  name: str
  signature: str

class DBusMethodInfo (TypedDict):

  annotations: list['DBusAnnotationInfo']

  in_args: list[DBusArgInfo]
  name: str
  out_args: list[DBusArgInfo]

class DBusSignalInfo (TypedDict):

  annotations: list['DBusAnnotationInfo']

  args: list[DBusArgInfo]
  name: str

class DBusPropertyInfo (TypedDict):

  annotations: list['DBusAnnotationInfo']

  flags: int
  name: str
  signature: str

class DBusInterfaceInfo (TypedDict):

  annotations: list['DBusAnnotationInfo']

  methods: list[DBusMethodInfo]
  name: str
  properties: list[DBusPropertyInfo]
  signals: list[DBusSignalInfo]