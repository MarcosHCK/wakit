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

  public interface IModule: GLib.Object, GLib.Initable
    {

      public abstract unowned IModuleHost host { get; construct; }

      [Compact (opaque = false)] internal class LoaderMapEntry
        {

          public string expected_mime_type;
          public GLib.Type g_type;
          [CCode (array_length = false, array_null_terminated = true)]
          public string[] search_patterns;

          public LoaderMapEntry (GLib.Type g_type, string expected_mime_type, owned string[] search_patterns)
            {

              this.expected_mime_type = expected_mime_type;
              this.g_type = g_type;
              this.search_patterns = (owned) search_patterns;
            }
        }

      public static IModule create (string filename, string type, IModuleHost host, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          unowned LoaderMapEntry entry;

          if (unlikely (false == get_loader_entry (type, out entry)))
            throw new GLib.IOError.INVALID_ARGUMENT ("unknown module type '%s'", type);

          GLib.Type g_type = entry.g_type;

          var module = (IModule) GLib.Object.new (g_type, "filename", filename,
                                                          "host", host,
            null);

          module.init (cancellable);
        return module;
        }

      public static string? get_expected_mime_type (string type)
        {

          unowned LoaderMapEntry entry;

          if (unlikely (false == get_loader_entry (type, out entry)))
            return null;

        return entry.expected_mime_type;
        }

      static bool get_loader_entry (string type, out unowned LoaderMapEntry entry)
        {

          unowned GLib.HashTable<string, LoaderMapEntry> table = get_loader_mapping ();
          unowned string lookup_key = type;

        return table.lookup_extended (lookup_key, null, out entry);
        }

      [CCode (cheader_filename = "host/module/module.h")]
      private extern static unowned GLib.HashTable<string, LoaderMapEntry> get_loader_mapping ()
        requires (null != IModule.get_loader_mapping_once);

      internal static GLib.HashTable<string, LoaderMapEntry> get_loader_mapping_once ()
        {

          unowned GLib.HashFunc<string> hash_func = GLib.str_hash;
          unowned GLib.EqualFunc<string> key_equal_func = GLib.str_equal;

          var table = new GLib.HashTable<string, LoaderMapEntry> (hash_func, key_equal_func);

          table.insert ("c", new LoaderMapEntry (typeof (TypeModule),
                                                            TypeModule.EXPECTED_MIME_TYPE,
                                                            TypeModule.SEARCH_PATTERNS.split (",")));
        return table;
        }

      [CCode (array_length = false, array_null_terminated = true)] public static string[]? get_search_patterns (string type)
        {

          unowned LoaderMapEntry entry;

          if (unlikely (false == get_loader_entry (type, out entry)))
            return null;

        return entry.search_patterns;
        }

      public extern void set_host (IModuleHost host);
    }
}
