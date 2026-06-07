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
import { createRouter, RouterProvider } from '@tanstack/react-router'
import { defaultColorScheme, theme } from './theme'
import { MantineProvider } from '@mantine/core'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { routeTree } from '@wakit-example/routes.gen'

const queryClient = new QueryClient ()

const router = createRouter (
{
  defaultPreload: 'intent',
  routeTree,
  scrollRestoration: true,
})

declare module '@tanstack/react-router'
{
  interface Register { router: typeof router }
}

export default function App ()
{

  return <MantineProvider defaultColorScheme={defaultColorScheme} theme={theme}>
         <QueryClientProvider client={queryClient}>
           <RouterProvider router={router} />

  </QueryClientProvider> </MantineProvider>
}