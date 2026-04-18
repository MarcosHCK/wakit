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

  public interface IAttributable<T>: GLib.Object, IBinding<T>
    {

      JSC.Value? getter (string property_name)
        {

          unowned var context = JSC.Context.get_current ();
          JSC.Value? result = null;

          try
            { result = get_property (context, property_name); }
          catch (GLib.Error error)
            { Error.throw (context, (owned) error);  }
        return result;
        }

      public virtual JSC.Value? get_property (JSC.Context context, string property_name) throws GLib.Error
        {

          throw new GLib.IOError.FAILED ("unimplemented property getter");
        }

      JSC.Value? setter (string property_name, JSC.Value value)
        {

          unowned var context = JSC.Context.get_current ();
          JSC.Value? result = null;

          try
            { set_property (context, property_name, value); }
          catch (GLib.Error error)
            { Error.throw (context, (owned) error);  }
        return result;
        }

      public virtual void set_property (JSC.Context context, string property_name, JSC.Value value) throws GLib.Error
        {

          throw new GLib.IOError.FAILED ("unimplemented property setter");
        }

      public static void add_property (IBinding.Class klass, string field_name, string? property_name = null)
        {

          property_name = property_name ?? field_name;

          klass.jsc_class.add_property (field_name, typeof (JSC.Value),
            (s) => ((IAttributable<T>) s).getter (property_name),
            (s, v) => ((IAttributable<T>) s).setter (property_name, (JSC.Value) v));
        }

      public static void add_property_no_getter (IBinding.Class klass, string field_name, string? property_name = null)
        {

          property_name = property_name ?? field_name;

          klass.jsc_class.add_property (field_name, typeof (JSC.Value),
            null,
            (s, v) => ((IAttributable<T>) s).setter (property_name, (JSC.Value) v));
        }

      public static void add_property_no_setter (IBinding.Class klass, string field_name, string? property_name = null)
        {

          property_name = property_name ?? field_name;

          klass.jsc_class.add_property (field_name, typeof (JSC.Value),
            (s) => ((IAttributable<T>) s).getter (property_name),
            null);
        }
    }
}