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

namespace Wakit.Binding
{

  internal sealed class BridgeTypes: GLib.Object
    {

      private GLib.HashTable<string, GLib.Type> _types;

      public override void constructed ()
        {

          base.constructed ();

          unowned GLib.HashFunc<string> hash_func = GLib.str_hash;
          unowned GLib.EqualFunc<string> key_equal_func = GLib.str_equal;

          _types = new GLib.HashTable<string, GLib.Type> (hash_func, key_equal_func);
        }

      [CCode (cheader_filename = "glib.h", cname = "g_intern_string")]
      extern static unowned string _g_intern_string (string value);

      public unowned GLib.Type lookup (string name)
        {

          unowned GLib.Type g_type;

          if (! _types.lookup_extended (name, null, out g_type))
            _types.insert (name, g_type = make_type (name));

        return g_type;
        }

      private unowned GLib.Type make_type (string name)
        {

          unowned GLib.Type derived_type;
          unowned GLib.TypeFlags flag1 = GLib.TypeFlags.FINAL;
          unowned GLib.TypeFlags flags = flag1;
          unowned GLib.Type parent_type = typeof (ProxyBase);
          string tmp_name;

          tmp_name = ("WakitBindingBridgeType%s").printf (name);

          derived_type = _g_type_register_static_simple (parent_type,
            _g_intern_string (tmp_name),
            ProxyBase.SIZEOF_KLASS,
            (ClassInitFunc) make_type_class_init,
            ProxyBase.SIZEOF_INSTANCE,
            (InstanceInitFunc) make_type_instance_init,
            flags);
        return derived_type;
        }

      static void make_type_class_init (GLib.TypeClass klass, void* class_data)
        {
        }

      static void make_type_instance_init (GLib.TypeInstance instance, GLib.TypeClass klass)
        {
        }

      [CCode (cheader_filename = "glib-object.h", cname = "GClassInitFunc", has_target = false, scope = "forever")]
      extern delegate void ClassInitFunc (GLib.TypeClass klass, void* class_data);

      [CCode (cheader_filename = "glib-object.h", cname = "GInstanceInitFunc", has_target = false, scope = "forever")]
      extern delegate void InstanceInitFunc (GLib.TypeInstance instance, GLib.TypeClass klass);

      [CCode (cheader_filename = "glib-object.h", cname = "g_type_register_static_simple")]
      extern static GLib.Type _g_type_register_static_simple (GLib.Type parent_type, string type_name, size_t class_size, ClassInitFunc class_init, size_t instance_size,InstanceInitFunc instance_init, GLib.TypeFlags flags);
    }
}