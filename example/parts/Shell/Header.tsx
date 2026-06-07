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
import { Brand } from './Brand'
import { Controls } from './Controls'
import { Divider, Group, NavLink, Stack } from '@mantine/core'
import { Link } from '@tanstack/react-router'
import { type DividerProps, type NavLinkProps, type PolymorphicComponentProps } from '@mantine/core'
import { useCallback, useMemo } from 'react'
import * as css from './style.module.css'

export interface HeaderProps
{
  brandSize?: number;
  controlSize?: number;
  onNavigate?: () => void;
  size?: number;
  skipControls?: boolean;
  skipBrand?: boolean;
  skipLinks?: boolean;
  vertical?: boolean;
  withHome?: boolean;
}

export function Header (props: HeaderProps)
{

  const { brandSize = 30, controlSize = 40, onNavigate = () => {},
          skipControls, skipBrand, skipLinks, vertical, withHome } = props

  const divider = useCallback ((props: DividerProps) =>
    {

      const { style, ...rest } = props
      return ! vertical ? <></> : <Divider {...rest} style={{ ...style, minWidth: '100%' }} />
    }, [vertical])

  const link = useCallback ((props: { vertical?: boolean } & PolymorphicComponentProps<typeof Link, NavLinkProps>) =>
    {

      const { to, vertical: ovr = vertical, ...rest } = props

      const key = `nav(${to})`

      const nav = <NavLink {...rest}
                           className={css.appShellHeaderLink} component={Link} key={key}
                           onClick={() => onNavigate ()} p={7} to={to} />

      return !! ovr ? nav : <div key={key}>{ nav }</div>
    }, [onNavigate, vertical])

  const links = useMemo (() => (

    <>
      { withHome &&
          <>
            { link ({ label: 'Home', to: '/' }) }
          </> }
      { skipLinks ||
          <>
          </> }
      { skipControls ||
          <>
            <Controls size={controlSize} />
          </> }
    </> ), [divider, link, skipLinks, withHome])

  return <Group className={css.appShellHeaderBox}>

    { ! skipBrand &&
      link ({ leftSection: <span className={css.killNavLinkMargin}> <Brand size={brandSize} title='Wakit Example' /> </span>,
              p: 'xs', to: '/', vertical: false }) }
    { ! vertical ? <Group align='center'>{ links }</Group>
                 : <Stack align='start' gap={0} style={{ minWidth: '100%' }}>{ links }</Stack> }
    </Group>
}