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

module.exports =
{
  presets:
    [
      [ '@babel/preset-env', { targets: 'defaults' }],
      [ '@babel/preset-react', { runtime: 'automatic' }],
      '@babel/preset-typescript'
    ],
  plugins:
    [
      [ 'module-resolver', { 'root': './',
                             alias: { '@wakit-example': './' } } ]
    ],
}