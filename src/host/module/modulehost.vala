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

namespace Wakit.Host.Module
{

  /**
   * Keep well-known bus things in sync with extension/extension.ts
   * - note: the constants at the top (OBJECT_PATH := MODULE_OBJECT_PATH)
   */

  public interface IModuleHost: GLib.Object
    {

      public const string OBJECT_PATH = "/org/hck/wakit/Host/Module";

      public abstract ICollection<IPostable> postables { get; }
    }
}