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

  public class Error: GLib.Object, IBinding<Error>
    {

      public int code { get; construct; }
      public GLib.Quark domain { get; construct; }
      public string message { get; construct; }

      [PrintfFormat]
      public Error (GLib.Quark domain, int code, string fmt, ...)
        {

          var args = va_list ();
          var message = fmt.vprintf (args);

          Object (code: code, domain: domain, message: message);
        }

      public Error.literal (GLib.Quark domain, int code, string message)
        {

          Object (code: code, domain: domain, message: message);
        }

      public Error.take (owned GLib.Error error)
        {

          Object (code: error.code, domain: error.domain, message: error.message);
        }

      static JSC.Value make_thrower (JSC.Context context)
        {

          JSC.Value object;

          context.evaluate_in_object ("function __throw__ () { throw this }", -1,
                                      null, null,
                                      "extension://GError/throw", 1,
                                      out object);

          return object.object_get_property ("__throw__");
        }

      static JSC.Value query_int (int value)
        {
          unowned var context = JSC.Context.get_current ();
          return new JSC.Value.number (context, (double) value);
        }

      static JSC.Value query_string (string value)
        {
          unowned var context = JSC.Context.get_current ();
          return new JSC.Value.string (context, value);
        }

      public static unowned Class register (JSC.Context context)
        {

          unowned Class klass = IBinding<Error>.register (context, "GError");

          klass.jsc_class.add_property ("__throw__", typeof (JSC.Value),
            () => make_thrower (JSC.Context.get_current ()), null);

          klass.jsc_class.add_property ("code", typeof (JSC.Value), 
            s => query_int (((Error) s)._code), null);

          klass.jsc_class.add_property ("domain", typeof (JSC.Value),
            s => query_string (((Error) s)._domain.to_string ()), null);

          klass.jsc_class.add_property ("message", typeof (JSC.Value),
            s => query_string (((Error) s)._message.to_string ()), null);

          klass.jsc_class.add_method ("toString",
            s => ((Error) s).to_string (), typeof (JSC.Value));

        return klass;
        }

      public static void @throw (JSC.Context context, owned GLib.Error error)
        {

          var value = (new Error.take ((owned) error)).to_value (context);
          value.object_invoke_methodv ("__throw__", null);
        }

      private JSC.Value to_string ()
        {

          var value = "%s: %u: %s".printf (_domain.to_string (), _code, _message);
          return new JSC.Value.string (JSC.Context.get_current (), value);
        }

      public JSC.Value to_value (JSC.Context context)
        {

          return IBinding<Error>.to_value (context, this);
        }
    }
}