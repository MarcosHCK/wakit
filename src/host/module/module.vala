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

      public abstract unowned Host host { get; construct; }

      public static IModule create (string filename, string type, Host host, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          GLib.Type g_type;
          unowned var table = get_loader_mapping ();
          unowned string lookup_key = type;

          if (! table.lookup_extended (lookup_key, null, out g_type))
            throw new GLib.IOError.INVALID_ARGUMENT ("unknown module type '%s'", type);

          var module = (IModule) GLib.Object.new (g_type, "filename", filename,
                                                          "host", host,
            null);

          module.init (cancellable);
        return module;
        }

      [CCode (cheader_filename = "host/module/module.h")]
      private extern static unowned GLib.HashTable<string, GLib.Type> get_loader_mapping ()
        requires (null != IModule.get_loader_mapping_once);

      internal static GLib.HashTable<string, GLib.Type> get_loader_mapping_once ()
        {

          unowned GLib.HashFunc<string> hash_func = GLib.str_hash;
          unowned GLib.EqualFunc<string> key_equal_func = GLib.str_equal;

          var table = new GLib.HashTable<string, GLib.Type> (hash_func, key_equal_func);

          table.insert ("c", typeof (TypeModule));
        return table;
        }

      public extern void set_host (Host host);
    }
}
