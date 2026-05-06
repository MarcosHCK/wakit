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

  internal sealed class Name
    {

      public string name { get; private set; }

      public Server? server { owned get { return (Server?) _server.get (); }
                            private set { _server.set (value); } }

      public NameOwner? owner { get; private owned set; default = null; }

      private GLib.WeakRef _server;

      public Name (string name, Server server)
        {

          _name = name;
          _server.set (server);
        }
    }
}