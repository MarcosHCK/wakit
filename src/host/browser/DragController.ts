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

export class DragController
{

  private _callbacks: ([ keyof HTMLElementEventMap, (() => void) ])[]
  private _debounce: number
  private _down: boolean
  private _element: HTMLElement
  private _timeout: number

  constructor (element: HTMLElement, debounce: number = 50)
    {

      this._callbacks = []
      this._debounce = debounce
      this._down = false
      this._element = element
      this._timeout = -1
      this.init ()
    }

  private addCallback<T extends (...args: any[]) => void> (type: keyof HTMLElementEventMap, callback: T):
      [ keyof HTMLElementEventMap, T ]
    {

      this._callbacks.push ([ type, callback ])
    return [ type, callback ]
    }

  public dispose ()
    {

      this.disposeDown ()
      this.disposeTimeout ()

      for (const callback of this._callbacks)
        this._element.removeEventListener (...callback)
    }

  private disposeDown ()
    {

      if (!! this._down)
        browserWindow.drag (false).catch (console.error)
    }

  private disposeTimeout ()
    {

      if (0 <= this._timeout)
        clearTimeout (this._timeout)
    }

  private init ()
    {

      logging.debug (`add drag controller (${this._debounce} ms debounce)`)

      this._element.addEventListener (...this.addCallback ('mousedown', (ev: Event) =>
        {

          this.disposeTimeout ()
          this._timeout = setTimeout (() => this._down = true, this._debounce)
        }))

      this._element.addEventListener (...this.addCallback ('mousemove', (ev: Event) =>
        {

          if (this._down)
            {
              this._element.setAttribute ('data-wakit-drag-area-active', 'true')
              browserWindow.drag (this._down = true)
            }
        }))

      this._element.addEventListener (...this.addCallback ('mouseup', (ev: Event) =>
        {

          this.disposeTimeout (); if (this._down)
            {
              this._element.removeAttribute ('data-wakit-drag-area-active')
              browserWindow.drag (this._down = false)
            }
        }))
    }
}