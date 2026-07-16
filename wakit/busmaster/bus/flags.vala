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

namespace Wakit.Busmaster.Bus
{

  [Flags]
  internal enum NameFlags
    {
      ALLOW_REPLACEMENT = (1 << 0),
      REPLACE_EXISTING = (1 << 1),
      DO_NOT_QUEUE = (1 << 2),
    }

  internal enum ReleaseNameReply
    {
      RELEASED = 1,
      NON_EXISTENT = 2,
      NOT_OWNER = 3,
    }

  internal enum RequestNameReply
    {
      PRIMARY_OWNER = 1,
      IN_QUEUE = 2,
      EXISTS = 3,
      ALREADY_OWNER = 4,
    }

  internal enum StartServiceReply
    {
      SUCCESS = 1,
      ALREADY_RUNNING = 2,
    }
}