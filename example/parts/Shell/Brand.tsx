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
import { Center, getFontSize } from '@mantine/core'
import { useImage } from '@wakit-example/hooks/useImage'
import * as css from './style.module.css'

export function Brand ({ size = 24, title }: { size?: number, title?: string })
{

  const data = useImage ('/favicon.ico')

  return  <Center>
            <img alt='ICON' height={size} src={data?.src} style={{ borderRadius: '100%' }} width={size} />
          { title && <>
            <span className={css.brandSeparator} />
            <span className={css.brandText} style={{ fontSize: getFontSize (size) }} >{ title }</span> </> }
          </Center>
}