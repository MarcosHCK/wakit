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

namespace Wakit.Bundle
{

  public sealed class Bundle: GLib.Object
    {

      public GLib.List<weak Alias> aliases { owned get { return _aliases.copy (); } }
      public GLib.Resource bundle { get; construct; }

      private GLib.List<Alias> _aliases = new GLib.List<Alias> ();

      public Bundle (GLib.Resource resource)
        {

          Object (bundle: resource);
        }

      public Bundle.from_file (string filename) throws GLib.Error
        {

          GLib.Resource resource = GLib.Resource.load (filename);
          Object (bundle: resource);
        }

      public void add_alias (Alias alias)
        {

          _aliases.append (alias);
        }

      public GLib.InputStream? lookup (string path) throws GLib.Error
        {

          size_t length = path.length;

          foreach (unowned var alias in _aliases)
            {

              if (! alias.matches (path, length))
                continue;

              string new_path = alias.replace (path, length);

              try
                { return _bundle.open_stream (new_path, 0); }
              catch (GLib.ResourceError.NOT_FOUND error)
                { continue; }
            }
        return null;
        }

      public GLib.Bytes? lookup_data (string path) throws GLib.Error
        {

          size_t length = path.length;

          foreach (unowned var alias in _aliases)
            {

              if (! alias.matches (path, length))
                continue;

              string new_path = alias.replace (path, length);

              try
                { return _bundle.lookup_data (new_path, 0); }
              catch (GLib.ResourceError.NOT_FOUND error)
                { continue; }
            }

          throw new GLib.IOError.NOT_FOUND ("not found");
        }
    }
}