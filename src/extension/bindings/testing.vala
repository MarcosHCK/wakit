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

  public class Testing: GLib.Object, IBinding<Testing>, IAttributable<Testing>
    {

      public new JSC.Value IAttributable.get_property (JSC.Context context, string property_name)
        {

          message (@"get property $property_name");
          return new JSC.Value.string (context, property_name);
        }

      public static unowned Class register (JSC.Context context)
        {

          unowned Class klass = IBinding<Testing>.register (context, "Testing");

          klass.add_default_ctor (typeof (Testing));

          IAttributable<Testing>.add_property (klass, "property1");
          IAttributable<Testing>.add_property (klass, "property2", "property2_with_alias");

          IInvocable<Testing>.add_method (klass, "test_promise", (s, a) => s.test_promise (a));
          IInvocable<Testing>.add_method (klass, "test_simple_promise", (s, a) => s.test_simple_promise (a));
          IInvocable<Testing>.add_method (klass, "test_throw", (s, a) => s.test_throw (a));
          IInvocable<Testing>.add_method (klass, "test_throw_promise", (s, a) => s.test_throw_promise (a));

        return klass;
        }

      public new void IAttributable.set_property (JSC.Context context, string property_name, JSC.Value value)
        {

          message (@"set property $property_name");
        }

      private JSC.Value test_promise (GenericArray<JSC.Value> args)
        {

          unowned var context = JSC.Context.get_current ();

          JSC.Value arg1 = null;
          uint interval = 1000;

          if (args.length > 0 && (arg1 = args [0]).is_number ())
            interval = (uint) (arg1.to_double () * 1000.0f);

          return Promise.create (context, p =>
            {

              var source = new TimeoutSource (interval);

              source.set_callback (() => { p.resolve (new JSC.Value.number (p.context, GLib.Random.next_double ()));
                                                return GLib.Source.REMOVE; });
              source.attach ();
            });
        }

      private JSC.Value test_simple_promise (GenericArray<JSC.Value> args)
        {

          unowned var context = JSC.Context.get_current ();

          JSC.Value arg1 = null;
          uint interval = 1000;

          if (args.length > 0 && (arg1 = args [0]).is_number ())
            interval = (uint) (arg1.to_double () * 1000.0f);

          return Promise.simple (context, (resolve, reject) =>
            {

              var context2 = JSC.Context.get_current ();
              var source = new TimeoutSource (interval);

              source.set_callback (() => { resolve.function_callv ({ new JSC.Value.number (context2, GLib.Random.next_double ()) });
                                                return GLib.Source.REMOVE; });
              source.attach ();
            });
        }

      private JSC.Value? test_throw (GenericArray<JSC.Value> args)
        {

          unowned var context = JSC.Context.get_current ();

          Error.throw (context, new GLib.Error.literal (IOError.quark (), IOError.FAILED, "just testing"));
        return null;
        }

      private JSC.Value test_throw_promise (GenericArray<JSC.Value> args)
        {

          unowned var context = JSC.Context.get_current ();

          JSC.Value arg1 = null;
          uint interval = 1000;

          if (args.length > 0 && (arg1 = args [0]).is_number ())
            interval = (uint) (arg1.to_double () * 1000.0f);

          return Promise.simple (context, (resolve, reject) =>
            {

              var context2 = JSC.Context.get_current ();
              var error = new GLib.Error.literal (IOError.quark (), IOError.FAILED, "just testing");
              var source = new TimeoutSource (interval);

              source.set_callback (() => { reject.function_callv ({ (new Error.take (error)).to_value (context2) });
                                                return GLib.Source.REMOVE; });
              source.attach ();
            });
        }
    }
}