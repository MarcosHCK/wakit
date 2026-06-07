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
import { createFileRoute } from '@tanstack/react-router'
import { Stack } from '@mantine/core'
import { useQuery } from '@tanstack/react-query'

export const Route = createFileRoute ('/') (
{
  component: Page,
})

function Page ()
{

  const { data: numbers } = useQuery (
    {

      queryFn: async () =>
        {

          const client = bridge.Interface
          const numbers = await client.RandomNumbers ()
          const value = numbers.reduce ((a, e) => '' === a ? `${e}` : `${a}, ${e}`, '')
        return value
        },

      queryKey: [ 'interface', 'RandomNumbers' ]
    })

  return <Stack>

    <p>Application showcase</p>
    <p>Numbers: { numbers }</p>
  </Stack>
}