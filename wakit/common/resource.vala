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

  public static GLib.Bytes lookup_build_resource (GLib.Resource resource, string path)
    {

      try
        {
          return resource.lookup_data (path, 0);
        }
      catch (GLib.ResourceError.NOT_FOUND error)
        {
          GLib.error ("missing build resource '%s'", path);
        }
      catch (GLib.Error error)
        {
          unowned uint code = error.code;
          unowned string domain = error.domain.to_string ();
          unowned string message = error.message.to_string ();

          GLib.error ("can not open build resource '%s': %s: %u: %s", path, domain, code, message);
        }
    }
}