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
import { createElement } from 'react'
import { createRoot } from 'react-dom/client'
import { App } from '@wakit-example/components/App'

const assert = function<T> (value: T, message?: string): T
{

  if (false === value || null === value || undefined === value)
    {

      console.error (message ?? 'assertion failed', value)
      throw new Error (message ?? 'assertion failed', { cause: value })
    }
return value
}

const body = assert (document.getElementsByTagName ('body')) [0]
const root = document.getElementById ('root')
           ?? body.appendChild (document.createElement ('div'))

const app = createElement (App, { root: (root.id = 'root', root as HTMLDivElement) })

createRoot ((root.id = 'root', root)).render (app)