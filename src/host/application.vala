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

namespace Wakit
{

  public class Application: Gtk.Application
    {

      private class string _bus_config_envvar = null;
      private class string _bus_executable_envvar = null;
      private class string _extension_dir = null;
      private class bool _launch_bus = false;

      public class void class_set_bus_config_envvar (string? envvar)
        {
          _bus_config_envvar = envvar;
        }

      public class void class_set_bus_executable_envvar (string? envvar)
        {
          _bus_executable_envvar = envvar;
        }

      public class void class_set_extension_dir (string? dir)
        {
          _extension_dir = dir;
        }

      public class void class_set_launch_bus (bool launch)
        {
          _launch_bus = launch;
        }
    }
}