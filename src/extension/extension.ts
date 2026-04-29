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

export type ProxyBase =
{
}

export type ProxyBuilder =
{
  create: (interface_name: string, object_path: string) => Promise<ProxyBase>
}

export type ProxyLister =
{
  list_path: (object_path: string) => Promise<string[]>
}

export const setup = async (page_id: string, proxyBuilder: ProxyBuilder, proxyLister: ProxyLister) =>
{

  await makeBridge (proxyBuilder, proxyLister)
  await makeBrowserWindow (page_id, proxyBuilder)
}

export const makeBridge = async (proxyBuilder: ProxyBuilder, proxyLister: ProxyLister) =>
{

  const object_path = '/org/hck/wakit/AppBus'

  const interfaces = await proxyLister.list_path (object_path)
  const typenames = interfaces.map (v => { let l = v.split ('.'); return l [l.length - 1] })
  const types = Object.fromEntries (Array.from ({ length: interfaces.length }).map ((_, i) => ([ typenames[i], interfaces[i] ])))

  const proxies: { [typename: string]: ProxyBase } = { }

  for (const [ typename, interface_name ] of Object.entries (types))
    {
      proxies [typename] = await proxyBuilder.create (interface_name, object_path)
    }

  ;(globalThis as unknown as { bridge: typeof proxies }).bridge = proxies
}

export const makeBrowserWindow = async (page_id: string, proxyBuilder: ProxyBuilder) =>
{

  const interface_name = 'org.hck.wakit.Browser.Window'
  const object_path = `/org/hck/wakit/AppBus/window/${page_id}`

  const proxy = await proxyBuilder.create (interface_name, object_path)

  ;(globalThis as unknown as { browserWindow: ProxyBase }).browserWindow = proxy
}