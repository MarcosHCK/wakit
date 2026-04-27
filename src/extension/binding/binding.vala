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

  public interface IBinding<T>: GLib.Object
    {

      [CCode (scope = "notify", type = "GCallback")]
      public delegate IBinding ConstructorCb (GenericArray<JSC.Value> args);

      [CCode (scope = "notify", type = "GCallback")]
      public delegate JSC.Value ConstructorFactoryCb (GenericArray<JSC.Value> args);

      [CCode (scope = "notify", type = "GCallback")]
      public delegate JSC.Value MethodVaCb (IBinding self, GenericArray<JSC.Value> args);

      [Compact (opaque = true)] public class Class
        {

          public JSC.Value ctor { get; private set; }
          public string ctor_name { get; private set; }
          public unowned JSC.Class jsc_class { get; private set; }
          public string name { get { return _jsc_class.get_name (); } }

          internal Class (JSC.Class jsc_class)
            {

              _jsc_class = jsc_class;
            }

          public unowned JSC.Value add_ctor (owned ConstructorCb callback, JSC.Value? namespace_ = null)
              requires (ctor == null)
            {

              unowned var name = _jsc_class.get_name ();
              unowned var return_type = typeof (GLib.Object);

              var cb = (JSC.ClassConstructorCb) (owned) callback;
              var ctor = _jsc_class.add_constructor (_ctor_name = name, (owned) cb, return_type);

              if (namespace_ != null) export_namespaced (namespace_);
            return (_ctor = ctor);
            }

          [CCode (cheader_filename = "jsc/jsc.h", cname = "jsc_value_new_function_variadic")]
          static extern JSC.Value _jsc_value_new_function_variadic (JSC.Context context, string? name, owned ConstructorFactoryCb callback, GLib.Type return_type);

          public JSC.Value add_ctor_factory (JSC.Context context, string name, owned ConstructorFactoryCb callback)
              requires (ctor != null)
            {

              var return_type = typeof (JSC.Value);
              var factory_func = _jsc_value_new_function_variadic (context, name, (owned) callback, return_type);
                _ctor.object_set_property (name, factory_func);
            return factory_func;
            }

          public unowned JSC.Value add_default_ctor (GLib.Type g_type, JSC.Value? namespace_ = null)
              requires (g_type.is_a (typeof (IBinding)))
            {

              return add_ctor (default_ctor_build (g_type), namespace_);
            }

          [CCode (cheader_filename = "extension/binding/binding.c", type = "GCallback")]
          extern static ConstructorCb default_ctor_build (GLib.Type g_type);

          public void export_global (JSC.Context context) requires (ctor != null)
            {

              context.set_value (_ctor_name, _ctor);
            }

          public void export_namespaced (JSC.Value namespace_) requires (ctor != null)
            {

              namespace_?.object_set_property (name, _ctor);
            }

          public static extern void free (owned Class self);
        }

      [CCode (cheader_filename = "extension/binding/binding.c")]
      extern const GLib.Quark TYPE_NAME_QUARK;

      [CCode (cheader_filename = "extension/binding/binding.c")]
      extern const GLib.Quark TYPE_PATH_QUARK;

      public new static unowned Class? get_class (JSC.Context context, GLib.Type g_type = typeof (T))
        {

          unowned Class? ibc_class;
          unowned string? cdp_path;

          if (unlikely (null == (cdp_path = (string?) g_type.get_qdata (TYPE_PATH_QUARK))))
            return null;

          if (unlikely (null == (ibc_class = context.get_data<Class?> (cdp_path))))
            return null;

        return ibc_class;
        }

      public static unowned Class must_get_class (JSC.Context context, GLib.Type g_type = typeof (T))
        {

          unowned Class? ibc_class;
          unowned string? cdp_path;

          if (unlikely (null == (cdp_path = (string?) g_type.get_qdata (TYPE_PATH_QUARK))))
            {
              unowned string name = g_type.name ();
              error ("trying to query an unregistered type (GType %s)", name);
            }

          if (unlikely (null == (ibc_class = context.get_data<Class?> (cdp_path))))
            {
              unowned string name = (string?) g_type.get_qdata (TYPE_NAME_QUARK);
              error ("trying to query an unregistered type (JSCClass %s)", name);
            }

        return ibc_class;
        }

      public static unowned Class register (JSC.Context context, string? name = null, GLib.Type g_type = typeof (T))
        {

          return register_full (context, name, g_type, null, null);
        }

      [CCode (cheader_filename = "glib.h", cname = "g_intern_string")]
      extern static unowned string _g_intern_string (string value);

      public static unowned Class register_full (JSC.Context context, string? name = null, GLib.Type g_type = typeof (T), JSC.Class? parent_class = null, JSC.ClassVTable? vtable = null)
        {

          name = null == name ? g_type.name () : _g_intern_string (name);

          unowned var jsc_class = context.register_class (name, parent_class, vtable, GLib.Object.unref);

          var ibc_class = new Class (jsc_class);
          var cdp_path = @"wakit-binding-for-$(g_type.name ())";

          g_type.set_qdata (TYPE_NAME_QUARK, name);
          g_type.set_qdata (TYPE_PATH_QUARK, _g_intern_string (cdp_path));

          unowned var backup = (Class) ibc_class;
          unowned var destroy = (GLib.DestroyNotify) Class.free;

          context.set_data_full (cdp_path, (void*) (owned) ibc_class, destroy);
        return backup;
        }

      public JSC.Value to_value (JSC.Context context)
        {

        return IBinding<T>.to_value_static (context, this, get_type ());
        }

      public static JSC.Value to_value_static (JSC.Context context, IBinding binding, GLib.Type g_type = typeof (T))
        {

          unowned var ibc_class = must_get_class (context, g_type);
          unowned var jsc_class = ibc_class.jsc_class;

        return new JSC.Value.object (context, binding.ref (), jsc_class);
        }
    }
}