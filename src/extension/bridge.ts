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
import { MODULE_OBJECT_PATH } from './constants'
import { type ProxyBase } from './ProxyBase'
import { type ProxyBuilder } from './ProxyBuilder'
import { type ProxyLister } from './ProxyLister'
import { TypenameBuilder } from './TypenameBuilder'

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

export const makeProxyListForName = async (name: string, proxyBuilder: ProxyBuilder, proxyLister: ProxyLister) =>
{

  const object_path = `${MODULE_OBJECT_PATH}/Types` as const
  const interfaces = await proxyLister.list_path (name, object_path)
  const typenameBuilder = await TypenameBuilder.create (name, proxyBuilder)
  const typenames = interfaces.map (v => typenameBuilder.build (v))
  const types = [] as [ typename: string, proxyBase: ProxyBase ][]

  for (let i = 0; i < interfaces.length; ++i)
    types.push ([ typenames[i], await proxyBuilder.create (name, interfaces[i], object_path) ])

return types
}