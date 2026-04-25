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
import { DataAttrWatcher } from './DataAttrWatcher'
import { DragController } from './DragController'

const dragControllers = new Map<HTMLElement, DragController> ()

const dataDragAreaWatcher = new DataAttrWatcher ('data-wakit-drag-area', elements =>
{

  for (const element of elements) if (element instanceof HTMLElement)

    { const attr = element.getAttribute ('data-wakit-drag-area')
      const span = Number (attr)

      dragControllers.set (element, new DragController (element, !isNaN (span) ? span : undefined)) }
  else
    console.warn (element, "invalid use of attribute 'data-wakit-drag-area'")
})