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

export type DataAttrWatcherCallback = (elements: Element[]) => void

export class DataAttrWatcher
{

  private _attributeName: string;
  private _callback: DataAttrWatcherCallback;
  private _observer?: MutationObserver;

  constructor (attributeName: string, callback: DataAttrWatcherCallback)
    {

      this._attributeName = attributeName
      this._callback = callback

      this.init ();
    }

  private findAndAddNodes ()
    {

      const allNodes = document.querySelectorAll (`[${this._attributeName}]`)
      this.notifyAdded (allNodes)
    }

  private findNodesInSubtree (root: Element)
    {

      const nodes = []

      if (root.hasAttribute && root.hasAttribute (this._attributeName))
        nodes.push (root)

      const descendants = root.querySelectorAll (`[${this._attributeName}]`)

      nodes.push (...descendants)
    return nodes
    }

  private init (): void
    {

      this.findAndAddNodes ()

      this._observer = new MutationObserver ((m) => this.watch (m))

      this._observer.observe (document.body, { attributes: true,
                                               attributeFilter: [ this._attributeName ],
                                               childList: true,
                                               subtree: true, })
    }

  private notifyAdded (nodes: Iterable<Element>)
    {

      const nodeList = [ ...nodes ]
      if (nodeList.length > 0) this._callback (nodeList)
    }

  private watch (mutations: MutationRecord[]): void
    {

      for (const mutation of mutations)
        {

          for (const added of mutation.addedNodes) if (Node.ELEMENT_NODE === added.nodeType)
            {

              const nodesToAdd = this.findNodesInSubtree (added as Element)
              this.notifyAdded (nodesToAdd)
            }

          if ('attributes' === mutation.type && this._attributeName == mutation.attributeName)
            {

              const target = mutation.target

              if ((target as Element).hasAttribute (this._attributeName))
                this.notifyAdded ([ target as Element ])
            }
        }
    }
}