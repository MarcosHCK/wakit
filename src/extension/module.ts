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
import { BUS_NAME, BUS_OBJECT_PATH } from './constants'
import { type ModuleRegistry } from './ModuleRegistry'
import { type ProxyBuilder } from './ProxyBuilder'

export const listModuleNames = async (proxyBuilder: ProxyBuilder) =>
{

  const interface_name = 'org.hck.wakit.Host.Module.Registry'
  const object_path = BUS_OBJECT_PATH

  const proxy = await proxyBuilder.create (BUS_NAME, interface_name, object_path)
  const names = await (proxy as ModuleRegistry).list_names ()
return names
}