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
import { BrowserRouter, Route, Routes } from 'react-router-dom'
import { Catch } from '@wakit-example/parts/Error/Overlay'
import { Center, Loader, MantineProvider } from '@mantine/core'
import { defaultColorScheme, theme } from './theme'
import { ErrorBoundary } from 'react-error-boundary'
import { QueryClient, QueryClientProvider, useSuspenseQuery } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import { routes } from '@wakit-example/routes'
import { type ReactNode, Suspense } from 'react'

const queryClient = new QueryClient ()

export function Root ()
{

  return <MantineProvider defaultColorScheme={defaultColorScheme} theme={theme}>
         <QueryClientProvider client={queryClient}>
         <ErrorBoundary FallbackComponent={Catch}>
         <Suspense fallback={<Center h='100vh'> <Loader /> </Center>}>

            <BrowserRouter> <Shell> <Routes>{ routes.map (e => <Route {...e} />) }</Routes>
                            </Shell>
            </BrowserRouter>
         </Suspense> </ErrorBoundary>
      <ReactQueryDevtools buttonPosition='bottom-right' position='bottom' />
  </QueryClientProvider> </MantineProvider>
}

export function Shell ({ children }: { children: ReactNode })
{

  const { data: Component, error, isFetching } = useSuspenseQuery (
    {
      queryFn: async () => (await import ('@wakit-example/parts/Shell')).Shell,
      queryKey: [ 'import', 'part', 'Shell' ],
      staleTime: 'static',
    })

  if (error && false === isFetching) throw error

return <Component>{ children }</Component>
}