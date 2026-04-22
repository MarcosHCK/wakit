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

/**
 * @template T
 * @param {T} value
 * @param {(value: T) => boolean} checker
 * @param {string | ((value: T) => string) | undefined} message
 * @returns {T}
 */
function assert (value, checker, message = undefined)
{

  if (checker (value))
    return value

  if ('function' == typeof message)

    throw new Error (message (value))
  else
    throw new Error (message ?? 'precondition fails')
}

/**
 * @typedef {[string,[string,number,number]]} CodeLoc
 */

/**
 * @param {ErrorConstructor} ctor
 * @returns {CodeLoc}
 */
export const makeCodeloc = (ctor) => function (at = 1)
{

  const error = ctor ();
  /** @type {string} */
  const stack = assert (error.stack, v => v !== undefined, 'missing stack field');

  const lines = assert (stack.split ('\n'), v => v.length > at, 'too few stack level')
  const level = lines [at]

  const at_fragments = assert (level.split ('@'), v => v.length == 2, 'malformed stack level line')
  const func_name = at_fragments [0]

  if ('' == at_fragments [1])
    return [ func_name, [ '', 0, 0 ] ]

  const dd_fragments = assert (at_fragments [1].split (':'), v => v.length >= 3, 'malformed stack level line')

  /** @type {string} */
  const file_uri = Array.from ({ length: dd_fragments.length - 2 }).reduce ((a, _, i) => (a == '' ? a : a + ':') + dd_fragments [i], '')

  const column = assert (Number (dd_fragments [dd_fragments.length - 1]), v => !isNaN (v), 'malformed stack location bit')
  const line = assert (Number (dd_fragments [dd_fragments.length - 2]), v => !isNaN (v), 'malformed stack location bit')

return [ func_name, [ file_uri, line, column ] ]
}

/**
 * @param {(level?: number) => CodeLoc} codeloc 
 * @param {number} level 
 * @param {(domain: string, level: number, ...args: any) => void} log
 * @param {string} priority 
 * @returns 
 */
export const makeLogFunc = (codeloc, level, log, priority) => function (...args)
{

  const domain = 'Wakit.Javascript'
  const message = args.map (e => `${e}`).join (' ')

  const [ func, [ file, line, coln ] ] = codeloc (2)

  const fields = [ 'PRIORITY', priority,
                   'CODE_COLUMN', coln,
                   'CODE_FILE', file,
                   'CODE_FUNC', func,
                   'CODE_LINE', line,
                   'MESSAGE', message, ]

return log (domain, level, ...fields)
}