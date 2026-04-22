/* Copyright (C) 2025-2026 MarcosHCK
 * This file is part of wakit.
 *
 * wakit is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wakit is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

export type Serializer =
{
  add_key: (key: string) => void,
  add_value: (value: unknown) => void,
  close: () => void,
  open: () => void,
}

function perform (object: object, serializer: Serializer)
{

  for (const [ key, value ] of Object.entries (object))
    {
      serializer.open ()
      serializer.add_key (key)
      serializer.add_value (value)
      serializer.close ()
    }
}

export function serialize (object: object, serializer: Serializer)
{

  try
    { perform (object, serializer) }
  catch (error)
    { return error }
}