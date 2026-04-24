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
import '@mantine/core/styles.css'
import { AppIcon } from './AppIcon'
import { AppShell, Grid, Group, MantineProvider } from '@mantine/core'
import { defaultColorScheme, theme } from '@wakit-example/theme'
import { BrowserRouter, NavLink } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { Router } from '@wakit-example/components/Router'
import * as css from '@wakit-example/components/App.module.css'

const queryClient = new QueryClient ()

const headerHeightPx = 70 as const
const columns = 32 as const
const spaceSizes = { base: 0, sm: 1 } as const

const centerSizeTuples = Object.entries (spaceSizes).map (([b, s]) => [ b, columns - s * 2 ]) as readonly [string,number][]
const centerSizes = Object.fromEntries (centerSizeTuples)

export const App = ({ root }: { root: HTMLDivElement }) => <BrowserRouter>

  <QueryClientProvider client={queryClient}>
  <MantineProvider defaultColorScheme={defaultColorScheme} getRootElement={() => root} theme={theme}>

    <AppShell header={{ height: headerHeightPx }}
                padding='md'>

      <AppShell.Header data-wakit-drag-area>

        <Group className={css.appShellHeaderGroup}>

          <NavLink to='/' style={{ height: headerHeightPx - 13 * 2 }}>
            <AppIcon height={headerHeightPx - 13 * 2} />
          </NavLink>
        </Group>
      </AppShell.Header>

      <AppShell.Main className={css.appShellMain}>

        <Grid columns={columns} gutter={0}>

          <Grid.Col className={css.appShellMainCol} offset={spaceSizes} span={centerSizes}> <Router /> </Grid.Col>
        </Grid>
      </AppShell.Main>
    </AppShell>

  </MantineProvider> </QueryClientProvider>
</BrowserRouter>