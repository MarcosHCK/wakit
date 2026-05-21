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

const BUS_NAME = 'org.hck.wakit.AppBus' as const
const BUS_OBJECT_PATH = '/org/hck/wakit/AppBus' as const
const MODULE_OBJECT_PATH = "/org/hck/wakit/Host/Module" as const

export interface ProxyBase
{
}

export interface ProxyBuilder
{
  create: (bus_name: string, interface_name: string, object_path: string) => Promise<ProxyBase>;
}

export interface ProxyLister
{
  list_path: (bus_name: string, object_path: string) => Promise<string[]>;
}

export interface ModuleRegistry extends ProxyBase
{
  list_names: () => Promise<string[]>;
}

export const setup = async (page_id: string, proxyBuilder: ProxyBuilder, proxyLister: ProxyLister) =>
{

  try
    { await setupUnsafe (page_id, proxyBuilder, proxyLister) }
  catch (error)
    { logging.error (error) }
}

export const setupUnsafe = async (page_id: string, proxyBuilder: ProxyBuilder, proxyLister: ProxyLister) =>
{

  const globals = (globalThis as unknown as { bridge: Record<string, ProxyBase>; browserWindow: ProxyBase })
  const names = await listModuleNames (proxyBuilder)

  globals.bridge = await makeBridge (names, proxyBuilder, proxyLister)
  globals.browserWindow = await makeBrowserWindow (page_id, proxyBuilder)
}

export const listModuleNames = async (proxyBuilder: ProxyBuilder) =>
{

  const interface_name = 'org.hck.wakit.Host.Module.Registry'
  const object_path = BUS_OBJECT_PATH

  const proxy = await proxyBuilder.create (BUS_NAME, interface_name, object_path)
  const names = await (proxy as ModuleRegistry).list_names ()
return names
}

export const makeBridge = async (names: string[], proxyBuilder: ProxyBuilder, proxyLister: ProxyLister) =>
{

  const proxies = new Map<string, ProxyBase> ()

  for (const name of names)
  for (const [ typename, proxyBase ] of await makeProxyListForName (name, proxyBuilder, proxyLister))
    {

      if (false === proxies.has (typename))

        proxies.set (typename, proxyBase)
      else
        logging.warning (`duplicated bridge type '${typename}'`)
    }
return Object.fromEntries (proxies.entries ())
}

export const makeBrowserWindow = async (page_id: string, proxyBuilder: ProxyBuilder) =>
{

  const interface_name = 'org.hck.wakit.Browser.Window'
  const object_path = `${BUS_OBJECT_PATH}/windows/${page_id}`

  const proxy = await proxyBuilder.create (BUS_NAME, interface_name, object_path)

return proxy
}

export const makeProxyListForName = async (name: string, proxyBuilder: ProxyBuilder, proxyLister: ProxyLister) =>
{

  const object_path = MODULE_OBJECT_PATH
  const interfaces = await proxyLister.list_path (name, object_path)
  const typenames = interfaces.map (v => { let l = v.split ('.'); return l [l.length - 1] })
  const types = [] as [ typename: string, proxyBase: ProxyBase ][]

  for (let i = 0; i < interfaces.length; ++i)
    types.push ([ typenames[i], await proxyBuilder.create (name, interfaces[i], object_path) ])

return types
}