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
import { useMemo } from 'react'
import { useQuery } from '@tanstack/react-query'

function dataUrl (blob: Blob)
{
  const reader = new FileReader ()

  return new Promise<string> ((resolve, reject) =>
    {
      reader.onloadend = () => resolve (reader.result as string)
      reader.onerror = reject
      reader.readAsDataURL (blob)
    })
}

const fetchOptions: RequestInit =
{
  method: 'GET',
}

export type Image = HTMLImageElement

export async function queryFn (url: string, mimeTypes: string[], signal?: AbortSignal)
{
  const headers = { ...fetchOptions.headers, Accept: mimeTypes.join (',') }
  const options = { ...fetchOptions, headers, signal }
  let response: Response 

  if ((response = await fetch (url, options)).status === 200)

    return await dataUrl (await response.blob ())
  else
    throw Error (`'${url}' fetch error: ${response.status}`, { cause: 'fetch' })
}

export function queryKey (url: string | undefined, mimeTypes: string[])
{
  return [ 'image', 'blob', url, mimeTypes ]
}

export function useImage (url?: string, mimeTypes = [ 'image/png', 'image/svg+xml' ])
{

  const { data } = useQuery (
    { enabled: !! url,
      queryFn: async () => await queryFn (url!, mimeTypes),
      queryKey: queryKey (url, mimeTypes) })

  return useMemo (() =>
    { let img: Image
      return ! data ? undefined : (img = new Image (), img.src = data, img) }, [data])
}