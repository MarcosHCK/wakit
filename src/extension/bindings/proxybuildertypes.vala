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

  [Compact (opaque = true)]
  internal class ProxyBuilderTypes: GLib.HashTable<string, GLib.Type>
    {

      public ProxyBuilderTypes ()
        {

          unowned GLib.HashFunc<string> hash_func = GLib.str_hash;
          unowned GLib.EqualFunc<string> key_equal_func = GLib.str_equal;

          base (hash_func, key_equal_func);
        }

      [CCode (cheader_filename = "glib.h", cname = "g_intern_string")]
      extern static unowned string _g_intern_string (string value);

      public new GLib.Type add (JSC.Context context, GLib.DBusInterfaceInfo dbus_info, string name)
        {

          unowned GLib.Type derived_type;
          unowned GLib.TypeFlags flag1 = GLib.TypeFlags.FINAL;
          unowned GLib.TypeFlags flags = flag1;
          unowned GLib.Type parent_type = typeof (ProxyBase);
          string tmp_name;

          tmp_name = ("WakitBindingProxyType%u").printf (length);

          derived_type = _g_type_register_static_simple (parent_type,
            _g_intern_string (tmp_name),
            ProxyBase.SIZEOF_KLASS,
            (ClassInitFunc) derived_type_class_init,
            ProxyBase.SIZEOF_INSTANCE,
            (InstanceInitFunc) derived_type_instance_init,
            flags);

          ProxyBase.register (context, dbus_info, tmp_name, derived_type);
          insert (name, derived_type);

        return derived_type;
        }

      public new bool lookup (string name, out GLib.Type type)
        {

          return base.lookup_extended (name, null, out type);
        }

      static void derived_type_class_init (GLib.TypeClass klass, void* class_data)
        {
        }

      static void derived_type_instance_init (GLib.TypeInstance instance, GLib.TypeClass klass)
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