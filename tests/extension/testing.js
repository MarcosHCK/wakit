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

const keyPattern = /^[a-zA-Z_$][a-zA-Z0-9_$]*$/

/**
 * Nicely print an object key
 *
 * @param {string|symbol} key 
 * @returns 
 */
function toStringKey (key)
{

  return keyPattern.test (key) ? `${key}: `
                               : `"${key}": `
}

/**
 * Nicely string-fy any js value
 *
 * @param {any} value
 * @param {WeakSet<object>} seen
 * @returns {string}
 */
function toString (value, seen = new WeakSet ())
{

  if (null == value)
    return 'null'

  if (undefined == value)
    return 'undefined'

  switch (typeof value)
    {

    case 'bigint':
      return value.toString (10)

    case 'boolean':
      return value.toString ()

    case 'function':
      return `[Function ${value.name || 'anonymous'}]`

    case 'number':
      return value.toString (10)

    case 'object':
      {

        if (seen.has (value))
          return '[Object <circular>]'

        seen.add (value)

        if (Array.isArray (value))

          { const items = value.map (e => toString (e, seen))
            return `[ ${items.join (', ')} ]` }
        else if (value instanceof Int8Array)

          { const items = value.map (e => toString (e, seen))
            return `int8 [ ${items.join (', ')} ]` }
        else if (value instanceof Uint8Array)

          { const items = value.map (e => toString (e, seen))
            return `uint8 [ ${items.join (', ')} ]` }
        else if (value instanceof Int16Array)

          { const items = value.map (e => toString (e, seen))
            return `int16 [ ${items.join (', ')} ]` }
        else if (value instanceof Uint16Array)

          { const items = value.map (e => toString (e, seen))
            return `uint16 [ ${items.join (', ')} ]` }
        else if (value instanceof Int32Array)

          { const items = value.map (e => toString (e, seen))
            return `int32 [ ${items.join (', ')} ]` }
        else if (value instanceof Uint32Array)

          { const items = value.map (e => toString (e, seen))
            return `uint32 [ ${items.join (', ')} ]` }
        else
          { const items = Object.entries (value).map (t => toStringKey (t[0]) + toString (t[1], seen))
            return `{ ${items.join (', ')} }` }
      }

    case 'string':
      return `'${value}'`

    case 'symbol':
      return `[Symbol ${value.toString ()} ${value.description}]`

    default:
      return value.toString ()
    }
}