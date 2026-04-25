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
/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/no-namespace */

declare global
{

  namespace logging
    {

      type CodeLoc = [ chunkName: string, [ file: string, line: number, column: number ] ]

      enum LogLevel
        {

          CRITICAL,
          DEBUG,
          ERROR,
          INFO,
          MESSAGE,
          WARNING,
        }

      function codeloc (level?: number): CodeLoc;
      function critical (...values: any[]): void;
      function debug (...values: any[]): void;
      function error (...values: any[]): void;
      function info (...values: any[]): void;
      function message (...values: any[]): void;
      function warning (...values: any[]): void;

      function log (log_domain: string, log_level: LogLevel, ...first_field: any): void;
    }
}

export { }