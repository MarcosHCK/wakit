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

  public interface ILoader: GLib.Object
    {

      [Compact (opaque = true)] public class Info
        {

          public string content_type { get; }
          public size_t size { get; }

          public Info (string content_type, size_t size)
            {
              _content_type = content_type;
              _size = size;
            }
        }

      [Compact (opaque = true)] public class Resource
        {

          public Info info { get; }
          public GLib.InputStream stream { get; }

          public Resource (owned Info info, GLib.InputStream stream)
            {
              _info = (owned) info;
              _stream = stream;
            }
        }

      public abstract ICollection<Alias> aliases { get; }

      public abstract async Info get_info (string path, GLib.Cancellable? cancellable = null) throws GLib.Error;
      public abstract async GLib.InputStream open_stream (string path, GLib.Cancellable? cancellable = null) throws GLib.Error;

      public async Resource load (string path, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          var iter = aliases.iterator ();
          var length = path.length;

          for (unowned Alias alias; iter.next (out alias);)
            {

              if (! alias.matches (path, length))
                continue;

              string new_path = alias.replace (path, length);

              try
                { var info = yield get_info (new_path, cancellable);
                  var stream =  yield open_stream (new_path, cancellable);
                  return new Resource ((owned) info, stream); }
              catch (GLib.IOError.NOT_FOUND error)
                { continue; }
            }

          throw new GLib.IOError.NOT_FOUND (_ ("resource not found"));
        }
    }
}