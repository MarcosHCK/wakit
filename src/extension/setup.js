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

async (proxyBuilder, proxyLister) =>
{

  const object_path = '/org/hck/wakit/AppBus'

  /** @type {string[]} */
  const interfaces = await proxyLister.list_path (object_path)
  const typenames = interfaces.map (v => { let l = v.split ('.'); return l [l.length - 1] })
  const types = Object.fromEntries (Array.from ({ length: interfaces.length }).map ((_, i) => ([ typenames[i], interfaces[i] ])))

  /** @type {{ [typename: string]: object }} */
  const proxies = { }

  for (const [ typename, interface_name ] of Object.entries (types))
    {
      proxies [typename] = await proxyBuilder.create (interface_name, object_path)
    }

  globalThis.bridge = proxies
}