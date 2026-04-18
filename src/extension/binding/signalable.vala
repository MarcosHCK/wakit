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

  public interface ISignalable<T>: GLib.Object, IBinding<T>
    {

      public abstract Hub signal_hub { get; protected set; }

      public class Hub: GLib.Object
        {

          private ulong next = 0;
          private HashTable<string, Handlers> signals;

          [Compact (opaque = true)] class Handlers: GLib.Tree<ulong, JSC.Value>
            {

              public Handlers ()
                {

                  unowned GLib.CompareDataFunc<ulong> key_compare_func = compare;
                  base (key_compare_func);
                }

              static int compare (ulong a, ulong b)
                {

                return a > b ? 1 : (a == b ? 0 : -1);
                }
            }

          construct
            {

              unowned GLib.HashFunc<string> hash_func = GLib.str_hash;
              unowned GLib.EqualFunc<string> key_equal_func = GLib.str_equal;

              signals = new HashTable<string, Handlers> (hash_func, key_equal_func);
            }

          public new ulong connect (string name, JSC.Value callback)
            {

              unowned Handlers handlers;
              unowned ulong id;

              if (null == (handlers = signals.lookup (name)))
                {

                  var fail = new Handlers ();

                  handlers = fail;
                  signals.insert (name, (owned) fail);
                }

              handlers.insert (id = ++next, callback);
            return id;
            }

          public new void disconnect (ulong handler_id)
            {

              unowned Handlers handlers;

              for (var iter = HashTableIter<string, Handlers> (signals); iter.next (null, out handlers);)
                {

                  if (handlers.remove (handler_id))
                    break;
                }
            }

          public void emit (string name, GenericArray<JSC.Value> @params)
            {

              unowned Handlers handlers;

              if (likely (null != (handlers = signals.lookup (name))))
                emit_group (handlers, @params);
            }

          [CCode (cheader_filename = "extension/binding/signalable.c")]
          extern static void emit_group (GLib.Tree<ulong, JSC.Value> handlers, GenericArray<JSC.Value> @params);
        }

      private class Getter: GLib.Object, IBinding<Getter>
        {

          public Hub hub { construct; }
          public string signal_name { construct; }

          public Getter (Hub hub, string signal_name)
            {
              Object (hub: hub, signal_name: signal_name);
            }

          static JSC.Value? connect_ (JSC.Class c, GenericArray<JSC.Value> a)
            {

              unowned Getter getter = (Getter) c;

              if (a.length > 0 && a [0].is_function ())

                { ulong id = getter._hub.connect (getter._signal_name, a [0]);
                  return new JSC.Value.number (JSC.Context.get_current (), (double) id); }
              else
                { string got = a.length < 1 ? "nothing" : a [0].to_string ();
                  JSC.Context.get_current ().throw (@"expected callable argument, got $(got)"); }
            return null;
            }

          public static void register (JSC.Context context)
            {

              unowned GLib.Type g_type = typeof (Getter);
              unowned Class? klass;

              if (likely (null != (klass = get_class (context, g_type))))
                return;

              klass = IBinding<Getter>.register (context, "WakitSignalConnector");

              klass.jsc_class.add_method ("connect", (JSC.ClassMethodCb) connect_, typeof (JSC.Value));
            }
        }

      public static void add_signal (IBinding.Class klass, string field_name, string? signal_name = null)
        {

          signal_name = signal_name ?? field_name;

          JSC.ClassGetPropertyCb? getter = c => getter (c, signal_name);
          JSC.ClassSetPropertyCb? setter = null;

          klass.jsc_class.add_property (field_name, typeof (JSC.Value), (owned) getter, (owned) setter);
        }

      [CCode (cheader_filename = "glib-object.h", cname = "G_TYPE_FROM_INSTANCE")]
      extern static GLib.Type _G_TYPE_FROM_INSTANCE (void* instance);

      static JSC.Value? disconnect (JSC.Class c, GenericArray<JSC.Value> a)
        {

          if (a.length == 0 || false == a [0].is_number ())

            ((ISignalable) c).signal_hub.disconnect ((ulong) a [0].to_double ());
          else
            {

              unowned JSC.Context context = JSC.Context.get_current ();
              unowned GLib.Type g_type = _G_TYPE_FROM_INSTANCE (c);

              context.throw (@"$(get_class (context, g_type).name).disconnect expects a handler id");
            }
        return null;
        }

      public void emit (string name, GenericArray<JSC.Value> @params)
        {

          signal_hub.emit (name, @params);
        }

      static JSC.Value? getter (JSC.Class c, string signal_name)
        {

          var binding = new Getter (((ISignalable<T>) c).signal_hub, signal_name);
          var value = binding.to_value (JSC.Context.get_current ());
        return value;
        }

      public static void prepare (IBinding.Class klass, JSC.Context context)
        {

          Getter.register (context);
          klass.jsc_class.add_method ("disconnect", (JSC.ClassMethodCb) disconnect, typeof (JSC.Value));
        }
    }
}