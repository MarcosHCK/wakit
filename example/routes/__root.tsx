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
import { Catch, type CatchProps } from '@wakit-example/parts/Error'
import { createRootRoute, Outlet } from '@tanstack/react-router'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import { Shell } from '@wakit-example/parts/Shell'
import { TanStackRouterDevtools } from '@tanstack/react-router-devtools'

export const Route = createRootRoute (
{
  component: Root,
  errorComponent: Error,
})

function Error (props: CatchProps)
{

return <Shell> <Catch {...props} /> </Shell>
}

function Root ()
{

  return <> <Shell> <Outlet /> </Shell>
            <ReactQueryDevtools />
            <TanStackRouterDevtools />
         </>
}