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
/* eslint-disable @typescript-eslint/no-namespace */
import type { SignalSpec } from './signal'

declare global
{

  namespace browserWindow
    {

      function close (): Promise<boolean>;
      const closing: SignalSpec<[]>;
      function disconnect (signal_id: number): void;
      const maximized: boolean;
      const maximizedChanged: SignalSpec<[ boolean ]>;
      function maximizedToggle (): Promise<boolean>;
      const minimized: boolean;
      const minimizedChanged: SignalSpec<[ boolean ]>;
      function minimizedToggle (value?: boolean): Promise<boolean>;
    }
}

export { }