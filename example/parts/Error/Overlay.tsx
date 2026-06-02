/* Copyright (C) 2025 MarcosHCK
 * This file is part of uh-statistics.
 *
 * uh-statistics is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * uh-statistics is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with uh-statistics. If not, see <https://www.gnu.org/licenses/>.
 */
import { Catch as _Catch } from './Catch'
import { Overlay } from '@mantine/core'
import { type FallbackProps } from 'react-error-boundary'

export function Catch (props: FallbackProps)
{
  return <Overlay backgroundOpacity={0.20} blur={5} color='var(--mantine-color-body)'>
    <_Catch {...props} />
  </Overlay>
}