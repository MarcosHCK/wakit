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

namespace Wakit.Loaders
{

  public sealed class BundleLoader: GLib.Object, ILoader
    {

      public ICollection<Alias> aliases { get; }
      public GLib.Resource resource { get; construct; }

      public BundleLoader (GLib.Resource resource)
        {
          Object (resource: resource);
        }

      public BundleLoader.from_file (string filename) throws GLib.Error
        {
          Object (resource: GLib.Resource.load (filename));
        }

      public override void constructed ()
        {

          base.constructed ();
          _aliases = new ListCollection<Alias> ();
        }

      public async ILoader.Info get_info (string path, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          GLib.Bytes bytes;

          try
            { bytes = _resource.lookup_data (path, 0); }
          catch (GLib.ResourceError.NOT_FOUND error)
            { throw new GLib.IOError.NOT_FOUND (error.message); }

          string filename = path_filename (path);
          string content_type = GLib.ContentType.guess (filename, bytes.get_data (), null);

        return new Info (content_type, bytes.get_size ());
        }

      public async GLib.InputStream open_stream (string path, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          try
            { return _resource.open_stream (path, 0); }
          catch (GLib.ResourceError.NOT_FOUND error)
            { throw new GLib.IOError.NOT_FOUND (error.message); }
        }

      static string path_filename (string path)
        {

          string dirname = GLib.Path.get_dirname (path);
          string filename = ! path.has_prefix (dirname) ? path : path.substring (dirname.length, -1);
        return filename;
        }
    }
}