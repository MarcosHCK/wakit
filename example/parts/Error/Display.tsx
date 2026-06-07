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
export { _Error as Display }
import { ActionIcon, Collapse, Group, rem, Stack } from '@mantine/core'
import { BiSolidDownArrow, BiSolidRightArrow } from 'react-icons/bi'
import { PiArrowBendDownLeftLight } from 'react-icons/pi'
import { useDisclosure } from '@mantine/hooks'

function _Error ({ error }: { error: unknown })
{

  if ('object' !== typeof error)
    return <_ErrorUnknown error={error} />

  else if (error instanceof AggregateError)
    return <_ErrorAggregate error={error} />

  else if (error instanceof Error)
    return <_ErrorError error={error} />

  else
    return <_ErrorUnknown error={error} />
}

const expanderGap = 3
const expanderSize = 12
const expanderTab = expanderGap + expanderSize

function _ErrorAggregate ({ error }: { error: AggregateError })
{

  const [ open, { toggle } ] = useDisclosure (false)

  return <Stack gap={3}>

    <Group gap={expanderGap}>

      <ActionIcon onClick={toggle} size={expanderSize} variant='transparent'>

        { open ? <BiSolidDownArrow size={expanderSize} />
               : <BiSolidRightArrow size={expanderSize} /> }
      </ActionIcon>

      <p color='var(--notification-text-color)'
         style={{ marginBottom: '0px', marginTop: '0px' }}>
        Caught AggregateError: { error.message }
      </p>

      <_ThrowButton error={error} />
    </Group>

    <Collapse expanded={open}
              ml={rem (expanderTab)}
              transitionDuration={500}
              transitionTimingFunction='linear'>
      { // eslint-disable-next-line @eslint-react/no-array-index-key
        error.errors.map ((e, i) => <_Error error={e} key={i} />) }
    </Collapse>
  </Stack>
}

function _ErrorError ({ error }: { error: Error })
{

  return <Group gap={expanderGap} pl={rem (expanderTab)}>

    <p color='var(--notification-text-color)'
       style={{ marginBottom: '0px', marginTop: '0px' }}>
      Caught Error: { error.message }
    </p>

    <_ThrowButton error={error} />
  </Group>
}

function _ErrorUnknown ({ error }: { error: unknown })
{
  return <p>{ String (error) }</p>
}

function _ThrowButton ({ error }: { error: Error })
{

  const size = 15

  return <ActionIcon component='a'
                       onClick={() => console.error (error)}
                          size={size}
                       variant='transparent'>

      <PiArrowBendDownLeftLight color='var(--notification-text-color)' size={size} />
    </ActionIcon>
}