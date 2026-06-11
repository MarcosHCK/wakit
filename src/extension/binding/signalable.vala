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

      class Connector: GLib.Object, IBinding<Connector>, IInvocable<Connector>
        {

          public Hub hub { construct; }
          public string signal_name { construct; }

          public Connector (Hub hub, string signal_name)
            {
              Object (hub: hub, signal_name: signal_name);
            }

          static JSC.Value? connect_ (Connector c, GenericArray<JSC.Value> a)
            {

              if (a.length > 0 && a [0].is_function ())

                { ulong id = c._hub.connect (c._signal_name, a [0]);
                  return new JSC.Value.number (JSC.Context.get_current (), (double) id); }
              else
                { string got = a.length < 1 ? "nothing" : a [0].to_string ();
                  JSC.Context.get_current ().throw (@"expected callable argument, got $(got)"); }
            return null;
            }

          public static unowned Class register (JSC.Context context)
            {

              unowned Class klass = IBinding<Connector>.register (context, "Wakit.Binding.ISignalable.Connector");

              klass.jsc_class.add_method ("connect", (JSC.ClassMethodCb) connect_, typeof (JSC.Value));
            return klass;
            }

          public static unowned Class register_maybe (JSC.Context context)
            {

              unowned Class klass;

              if (likely (null != (klass = IBinding<Connector>.get_class (context))))

                return klass;
              else
                return register (context);
            }
        }

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

          [CCode (cheader_filename = "extension/binding/signalable.h")]
          extern static void emit_group (GLib.Tree<ulong, JSC.Value> handlers, GenericArray<JSC.Value> @params);

          public void emit_vr (string name, GLib.Variant @params) requires (@params.check_format_string ("r", false))
            {

              unowned Handlers handlers;

              if (likely (null != (handlers = signals.lookup (name))))
                emit_vr_group (handlers, @params);
            }

          [CCode (cheader_filename = "extension/binding/signalable.h")]
          extern static void emit_vr_group (GLib.Tree<ulong, JSC.Value> handlers, GLib.Variant @params);
        }

      public static void add_signal (IBinding.Class klass, string field_name, string? signal_name = null)
        {

          signal_name = signal_name ?? field_name;
          klass.jsc_class.add_property (field_name, typeof (JSC.Value), c => getter ((ISignalable<T> ) c, signal_name), null);
        }

      [CCode (cheader_filename = "glib-object.h", cname = "G_TYPE_FROM_INSTANCE")]
      extern static GLib.Type _G_TYPE_FROM_INSTANCE (void* instance);

      static JSC.Value? disconnect (JSC.Class c, GenericArray<JSC.Value> a)
        {

          if (a.length > 0)

            ((ISignalable) c).signal_hub.disconnect ((ulong) a [0].to_double ());
          else
            {

              unowned JSC.Context context = JSC.Context.get_current ();
              unowned GLib.Type g_type = _G_TYPE_FROM_INSTANCE (c);

              context.throw (@"$(get_class (context, g_type).name).disconnect expects a handler id");
            }
        return null;
        }

      static JSC.Value? getter (ISignalable<T> c, string signal_name)
        {

          var binding = new Connector (((ISignalable<T>) c).signal_hub, signal_name);
          var object = binding.to_value (JSC.Context.get_current ());

        return object;
        }

      sealed class ConnectorKeeper: GLib.Object
        { }

      public static void prepare (IBinding.Class klass, JSC.Context context)
        {

          unowned var _klass = Connector.register_maybe (context);
          klass.jsc_class.add_method ("disconnect", (JSC.ClassMethodCb) disconnect, typeof (JSC.Value));

          KlassReserve.preserve (context, _klass.jsc_class);
        }
    }
}