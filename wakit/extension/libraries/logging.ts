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

export type CodeLoc = [string,[string,number,number]]
export type Message<T> = string | ((value: T) => string) | undefined

function assert<T> (value: T, checker: (value: T) => boolean = (value: T) => undefined !== value,
                              message: Message<T> = undefined)
{

  if (checker (value))
    return value

  if ('function' == typeof message)

    throw new Error (message (value))
  else
    throw new Error (message ?? 'precondition fails')
}

export const makeCodeloc = (ctor: ErrorConstructor) => function (at = 1): CodeLoc
{

  const error = ctor ();
  const stack = assert (error.stack, v => v !== undefined, 'missing stack field') !;

  const lines = assert (stack.split ('\n'), v => v.length > at, 'too few stack level')
  const level = lines [at]

  const at_fragments = assert (level.split ('@'), v => v.length == 2, 'malformed stack level line')
  const func_name = at_fragments [0]

  if ('' == at_fragments [1])
    return [ func_name, [ '', 0, 0 ] ]

  const dd_fragments = assert (at_fragments [1].split (':'), v => v.length >= 3, 'malformed stack level line')

  const file_uri = Array.from ({ length: dd_fragments.length - 2 }).reduce<string> ((a, _, i) => (a == '' ? a : a + ':') + dd_fragments [i], '')

  const column = assert (Number (dd_fragments [dd_fragments.length - 1]), v => !isNaN (v), 'malformed stack location bit')
  const line = assert (Number (dd_fragments [dd_fragments.length - 2]), v => !isNaN (v), 'malformed stack location bit')

return [ func_name, [ file_uri, line, column ] ]
}

type CodeLocFunction = (at?: number) => CodeLoc
type LogFunction = (domain: string, level: number, ...args: any) => void

/**
 * @param {(level?: number) => CodeLoc} codeloc 
 * @param {number} level 
 * @param {(domain: string, level: number, ...args: any) => void} log
 * @param {string} priority 
 * @returns 
 */
export const makeLogFunc = (codeloc: CodeLocFunction, level: number, log: LogFunction, priority: string) => function (...args: unknown[])
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