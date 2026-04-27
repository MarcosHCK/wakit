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
import { AppShell, Burger, Grid, Group } from '@mantine/core'
import { Header } from './Header'
import { type ReactNode } from 'react'
import { useDisclosure, useMediaQuery } from '@mantine/hooks'
import * as css from './style.module.css'

const headerHeightPx = 80 as const
const breakpointWidthPx = 650 as const

const columns = 32 as const
const spaceSizes = { base: 0, sm: 1 } as const
const centerSizeTuples = Object.entries (spaceSizes).map (([b, s]) => [ b, columns - s * 2 ]) as readonly [string,number][]
const centerSizes = Object.fromEntries (centerSizeTuples)

export const Shell = ({ children }: { children?: ReactNode }) =>
{

  const [ opened, { close, toggle } ] = useDisclosure ()
  const desktop = useMediaQuery (`(min-width: ${breakpointWidthPx}px)`)

  return <AppShell header={{ collapsed: false,
                                 height: headerHeightPx }}
                   navbar={{ breakpoint: breakpointWidthPx,
                             collapsed: { desktop: true, mobile: !opened },
                                  width: '100%' }}
                  padding='md'>

  { desktop
    ? <AppShell.Header data-wakit-drag-area>

        <Header />
      </AppShell.Header>
    : <>
      
        <AppShell.Header data-wakit-drag-area>

          <Group className={css.appShellHeaderGroup}>

            <Burger opened={opened} onClick={toggle} />
            <Header skipBrand skipLinks />
          </Group>
        </AppShell.Header>

        <AppShell.Navbar>

          <Header skipAvatar skipBrand onNavigate={() => close ()} vertical withHome />
        </AppShell.Navbar>
      </>}

    <AppShell.Main className={css.appShellMain}>

      <Grid columns={columns} gutter={0}>

        <Grid.Col className={css.appShellMainCol} offset={spaceSizes} span={centerSizes}> { children } </Grid.Col>
      </Grid>
    </AppShell.Main>
  </AppShell>
}