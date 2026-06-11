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

  /*
   * WebKitGTK6 (specifically javascriptcore) has a weird bug, where a JSCClass's prototype (the
   * actual thing used by the engine to back the instances, not the object the C API returns)
   * isn't actually held by the JSCClass. If there are no instances and the GC runs, the prototype
   * will be erased and any further instantiation (even using the same JSCClass) will get an empty
   * prototype (all methods and properties gone). Will keep a dummy instance here.
   */

  public sealed class KlassReserve: GLib.Object, IBinding<KlassReserve>, IInvocable<KlassReserve>
    {

      const string global_name = "__klass_reserve";

      private GLib.SList<JSC.Value> _values = new GLib.SList<JSC.Value> ();

      class KlassPlaceholder: GLib.Object
        { }

      public static JSC.Value make_resident (JSC.Context context)
        {

          unowned Class klass;

          if (unlikely (null == (klass = get_class (context, typeof (KlassReserve)))))
            klass = register (context);

          var global = context.get_global_object ();
          var instance = new KlassReserve ();
          var reserve = new JSC.Value.object (context, (owned) instance, klass.jsc_class);

          global.object_define_property_data (global_name, 0, reserve);
        return reserve;
        }

      public static JSC.Value preserve (JSC.Context context, JSC.Class jsc_class)
        {

          var instance = new KlassPlaceholder ();

          JSC.Value global = context.get_global_object ();
          JSC.Value reserve;
          JSC.Value object = new JSC.Value.object (context, (owned) instance, jsc_class);
          JSC.Value parameters [1] = { object };

          if (unlikely (null == (reserve = global.object_get_property (global_name))))
            reserve = make_resident (context);

          reserve.object_invoke_methodv ("preserve", parameters);
        return object;
        }

      private JSC.Value? preserve_method (GenericArray<JSC.Value> args)
        {

          if (args.length < 1)
            {
              JSC.Context.get_current ().throw ("expected an argument");
              return null;
            }

          _values.prepend (args [0]);

        return new JSC.Value.boolean (JSC.Context.get_current (), true);
        }

      public static unowned Class register (JSC.Context context)
        {

          unowned Class klass = IBinding<KlassReserve>.register (context, "Wakit.KlassReserve");

          IInvocable<KlassReserve>.add_method (klass, "preserve", (c, a) => c.preserve_method (a));
        return klass;
        }
    }
}