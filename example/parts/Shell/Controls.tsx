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
import { Button, Group, rem, Stack } from '@mantine/core'
import { useEffect, useState, type ReactNode } from 'react'
import { FiMaximize2, FiMinimize2, FiMinus, FiX } from 'react-icons/fi'
import * as css from './style.module.css'

function collect<T> (p: Promise<T>)
{
  p.catch (e => console.error (e))
}

function Control ({ children, onClick, size = 30 }: { children?: ReactNode, onClick?: () => void, size?: number })
{

  return <Stack className={css.controlButtonContainer} style={{ '--button-size': rem (size) }}>

    <Button className={css.controlButton} onClick={onClick} radius={size} variant='subtle'>
      { children }
    </Button>
  </Stack>
}

export function Controls ({ size = 30 }: { size?: number })
{

  const [ maximized, setMaximized ] = useState (false)

  useEffect (() =>
    {

      const id = browserWindow.maximizedChanged.connect (setMaximized)
      return () => browserWindow.disconnect (id)
    }, [])

  return <Group gap={3} justify='end'>

    <Control onClick={() => collect (browserWindow.minimizedToggle ())} size={size}> <FiMinus /> </Control>
    <Control onClick={() => collect (browserWindow.maximizedToggle ())} size={size}> { ! maximized ? <FiMaximize2 /> : <FiMinimize2 /> } </Control>
    <Control onClick={() => collect (browserWindow.close ())} size={size}> <FiX /> </Control>
  </Group>
}