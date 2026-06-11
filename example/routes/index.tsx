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
import { createFileRoute, ErrorComponent } from '@tanstack/react-router'
import { Group, Stack, Textarea, UnstyledButton } from '@mantine/core'
import { PiArrowArcRight } from 'react-icons/pi'
import { type SignalSpec } from '@wakit/companion'
import { useEffect } from 'react'
import { useForm } from '@mantine/form'
import { useFormQuery } from '@wakit-example/hooks/useFormQuery'
import { useQuery } from '@tanstack/react-query'

export const Route = createFileRoute ('/') (
{
  component: Page,
})

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type __extract_interface_methods<T, Args extends unknown[] = any> = {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  [K in keyof T]: T[K] extends (...args: Args) => Promise<any> ? K : never;
}[keyof T]

type __extract_interface_signals<T> = {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  [K in keyof T]: T[K] extends SignalSpec<any[]> ? K : never;
}[keyof T]

type __interface_methods_a0 = __extract_interface_methods<typeof bridge.WakitExampleInterface, []>
type __interface_methods_a1 = Exclude<__extract_interface_methods<typeof bridge.WakitExampleInterface, [ string ]>, __interface_methods_a0>
type __interface_signals = __extract_interface_signals<typeof bridge.WakitExampleInterface>

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type __make_interface_field_props<T extends Record<string, (...args: any) => Promise<any>>, R = unknown> = {
  [K in keyof T]: { method_name: K;
                    transform?: (values: Awaited<ReturnType<T[K]>>) => R; }
}[keyof T]

type __interface_field_props<R> = __make_interface_field_props<Pick<typeof bridge.WakitExampleInterface, __interface_methods_a0>, R>

function InterfaceA0Field<TransformedValues = unknown> ({ method_name, transform }: __interface_field_props<TransformedValues>)
{

  const { data, error, refetch } = useQuery (
    {

      queryFn: async () => { const client = bridge.WakitExampleInterface
                             const numbers = await client [method_name] ()
        return numbers },
      queryKey: [ 'interface', method_name ]
    })

  const form = useForm<{ value: NonNullable<typeof data> }, TransformedValues> (
    {
      mode: 'controlled',
      transformValues: undefined === transform ? undefined : ({ value }) => (transform as (values: typeof data) => TransformedValues) (value),
    })

  useFormQuery (form, { value: data })
  useEffect (() => { if (form.initialized) form.reset () }, [data])

  const normal = <form onSubmit={form.onSubmit (() => {})}>

    <Group gap={3}>

      <Textarea label={`Field: ${method_name}`}
                rightSection={<UnstyledButton onClick={() => refetch ()}> <PiArrowArcRight /> </UnstyledButton>}
                style={{ flexGrow: 1 }}
                key={form.key ('value')} {...form.getInputProps ('value')} />

    </Group>
  </form>

return null === error ? normal : <ErrorComponent error={error} />
}

function Page ()
{

  return <Stack>

    <p>Application showcase</p>
    <InterfaceA0Field method_name='RandomNumbers' transform={(values) => values.reduce ((a, e) => '' === a ? `${e}` : `${a}, ${e}`, '')} />
    <InterfaceA0Field method_name='RandomUUID' />
    <InterfaceA0Field method_name='RandomUUIDs' transform={(values) => values.reduce ((a, e) => '' === a ? `${e}` : `${a}, ${e}`, '')} />
  </Stack>
}