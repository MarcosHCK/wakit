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
import { createRoot } from 'react-dom/client'
import { defaultColorScheme, theme } from './theme'
import { Center, Loader, MantineProvider } from '@mantine/core'
import { QueryClient, QueryClientProvider, useSuspenseQuery } from '@tanstack/react-query'
import { routes } from '@wakit-example/routes'
import React, { type ReactNode, Suspense } from 'react'

const queryClient = new QueryClient ()

const assert = function<T> (value: T, message?: string): T
{

  if (false === value || null === value || undefined === value)
    {

      console.error (message ?? 'assertion failed', value)
      throw new Error (message ?? 'assertion failed', { cause: value })
    }
return value
}

function Root ()
{

  return <BrowserRouter> <MantineProvider defaultColorScheme={defaultColorScheme} theme={theme}>
                         <QueryClientProvider client={queryClient}>
                         <Suspense fallback={<Center h='100vh'> <Loader /> </Center>}>
            <Shell>
              <Routes> { routes.map (e => <Route {...e} />) }</Routes>
            </Shell>
      </Suspense>
    </QueryClientProvider> </MantineProvider> </BrowserRouter>
}

function Shell ({ children }: { children: ReactNode })
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

const body = assert (document.getElementsByTagName ('body')) [0]

const root = document.getElementById ('root')
            ?? body.appendChild (document.createElement ('div'))

const router = React.createElement (Root)
const strict = React.createElement (React.StrictMode, { children: router })

createRoot ((root.id = 'root', root)).render (strict)