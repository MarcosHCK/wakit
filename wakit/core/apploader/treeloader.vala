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

  public sealed class TreeLoader: GLib.Object, ILoader
    {

      public ICollection<Alias> aliases { get; }
      public GLib.File tree_base { get; construct; }

      public TreeLoader (GLib.File tree_base)
        {
          Object (tree_base: tree_base);
        }

      public override void constructed ()
        {

          base.constructed ();
          _aliases = new ListCollection<Alias> ();
        }

      const string attribute1 = GLib.FileAttribute.STANDARD_CONTENT_TYPE;
      const string attribute2 = GLib.FileAttribute.STANDARD_SIZE;
      const string attributes = attribute1 + "," + attribute2;
      const int io_priority = GLib.Priority.DEFAULT;

      public async ILoader.Info get_info (string path, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          unowned var flags = GLib.FileQueryInfoFlags.NONE;
          unowned var rest = GLib.Path.skip_root (path);

          var file = tree_base.get_child (rest);
          var info = yield file.query_info_async (attributes, flags, io_priority, cancellable);
          var size = info.get_attribute_uint64 (attribute2);

        return new Info (info.get_content_type (), (size_t) size);
        }

      public async GLib.InputStream open_stream (string path, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          unowned var rest = GLib.Path.skip_root (path);

          var file = tree_base.get_child (rest);
          var stream = yield file.read_async (io_priority, cancellable);

        return stream;
        }
    }
}