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
import { Button, Group, Stack } from '@mantine/core'
import { Display } from './Display'
import { FallbackProps } from 'react-error-boundary'
import { PiArrowCounterClockwiseFill } from 'react-icons/pi'

export function Catch ({ error, resetErrorBoundary }: FallbackProps)
{

  return <Group h='100%' justify='center'>

    <Stack gap={7} h='100%' justify='center'>

      <Display error={error} />

      <Group justify='center'>

        <Button color = 'var(--mantine-color-dimmed)'
              onClick = {() => resetErrorBoundary ()}
                radius = 'xl'
              variant = 'light'> <PiArrowCounterClockwiseFill />
        </Button>
      </Group>
  </Stack> </Group>
}