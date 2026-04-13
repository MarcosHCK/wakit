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

  public class Testing: GLib.Object, IBinding<Testing>
    {

      public static unowned Class register (JSC.Context context)
        {

          unowned Class klass = IBinding<Testing>.register (context, "Testing");

          klass.add_default_ctor (typeof (Testing));
          klass.add_method_va ("test", (c, a) => ((Testing) c).test (a));
          klass.add_method_va ("test2", (c, a) => ((Testing) c).test2 (a));

        return klass;
        }

      private JSC.Value test (GenericArray<JSC.Value> args)
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

      private JSC.Value test2 (GenericArray<JSC.Value> args)
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
    }
}