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
import { makeBridge } from './bridge'
import { makeBrowserWindow } from './browserWindow'
import { listModuleNames } from './module'
import { type ProxyBase } from './ProxyBase'
import { type ProxyBuilder } from './ProxyBuilder'
import { type ProxyLister } from './ProxyLister'

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