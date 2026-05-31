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
import { MODULE_NAME, MODULE_OBJECT_PATH } from './constants'
import { type HostApplication } from './HostApplication'
import { type ProxyBuilder } from './ProxyBuilder'

export class TypenameBuilder
{

  constructor (public client_prefix: string,
               public server_prefix: string)
    { }

  public build (name: string)
    {

      if (name.startsWith (this.server_prefix))
        name = name.substring (this.server_prefix.length)

      const pieces = [ this.client_prefix,
                    ...TypenameBuilder.to_camel_case_ar (name) ]

    return pieces.join ('')
    }

  public static async create (bus_name: string, proxyBuilder: ProxyBuilder)
    {

      const interface_name = MODULE_NAME
      const object_path = MODULE_OBJECT_PATH

      const proxy = await proxyBuilder.create (bus_name, interface_name, object_path) as HostApplication

      const [ name_, type_prefix ] = await Promise.all ([ proxy.get_name (), proxy.get_type_prefix () ])
      const name = TypenameBuilder.to_camel_case_ar (name_).join ('')

    return new TypenameBuilder (name, type_prefix);
    }

  static to_camel_case_ar (value: string, separator: RegExp = /[\.-]/): string[]
    {

      return value.split (separator)
                  .filter (v => 0 < v.length).map (TypenameBuilder.to_camel_case_pc)
    }

  static to_camel_case_pc (value: string): string
    {

    return `${value[0].toUpperCase ()}${value.substring (1)}`
    }
}
