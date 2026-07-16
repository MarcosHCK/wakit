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

namespace Wakit
{

  internal sealed class ObjectSerializer: GLib.Object
    {

      private unowned GLib.VariantType _dict_entry_type;
      private unowned GLib.VariantType _key_type;
      private unowned GLib.VariantType _value_type;
      private GLib.VariantBuilder _builder;
      private GLib.VariantType _type;

      public unowned GLib.VariantType variant_type { construct
        {
          _type = (GLib.VariantType) value.dup_string ();
        } }

      class construct
        {

          if (null == (void*) ObjectSerializer.finish)
            error ("WTF?");

          if (null == (void*) ObjectSerializer.get_class)
            error ("WTF?");
        }

      public ObjectSerializer (GLib.VariantType variant_type)
        {
          Object (variant_type: variant_type);
        }

      public override void constructed ()
        {

          _dict_entry_type = _type.element ();

          _key_type = _dict_entry_type.first ();
          _value_type = _key_type.next ();

          _builder = new GLib.VariantBuilder (_type);
        }

      public new static unowned JSC.Class get_class (JSC.Context context)
        {

          unowned JSC.Class jsc_class;

          if (likely (null != (jsc_class = context.get_qdata<JSC.Class> (KLASS_QUARK))))

            return jsc_class;
          else
            return register (context);
        }

      static JSC.Value? add_key (JSC.Class c, GenericArray<JSC.Value> args)
        {

          ((ObjectSerializer) c).add_whole (args, ((ObjectSerializer) c)._key_type);
        return null;
        }

      static JSC.Value? add_value (JSC.Class c, GenericArray<JSC.Value> args)
        {
          ((ObjectSerializer) c).add_whole (args, ((ObjectSerializer) c)._value_type);
        return null;
        }

      private void add_whole (GenericArray<JSC.Value> args, GLib.VariantType type)
        {

          unowned JSC.Context context = JSC.Context.get_current ();

          try
            { var argument = args.length > 0 ? args [0] : new JSC.Value.undefined (context);
              var variant = Marshalling.jsc_value_to_variant (context, type, argument);
              _builder.add_value (variant); }
          catch (GLib.Error error)
            { Error.throw (context, (owned) error); }
        }

      static JSC.Value? close (JSC.Class c, GenericArray<JSC.Value> args)
        {

          ((ObjectSerializer) c)._builder.close ();
        return null;
        }

      [CCode (returns_floating_reference = true)] public GLib.Variant finish ()
        {

          return _builder.end ();
        }

      static JSC.Value? open (JSC.Class c, GenericArray<JSC.Value> args)
        {

          ((ObjectSerializer) c)._builder.open (((ObjectSerializer) c)._dict_entry_type);
        return null;
        }

      [CCode (cheader_filename = "wakit/extension/utility/objectserializer.c")]
      extern const GLib.Quark KLASS_QUARK;

      [CCode (cheader_filename = "glib-object.h", cname = "g_object_set_qdata")]
      extern static void _g_object_set_qdata (GLib.Object object, GLib.Quark quark, void* data);

      public static unowned JSC.Class register (JSC.Context context)
        {

          unowned GLib.DestroyNotify destroy_notify = GLib.Object.unref;
          unowned JSC.Class? parent_class = null;
          unowned JSC.ClassVTable? vtable = null;

          unowned JSC.Class klass = context.register_class ("WakitObjectSerializer", parent_class, vtable, destroy_notify);

          klass.add_method ("add_key", (JSC.ClassMethodCb) add_key, typeof (JSC.Value));
          klass.add_method ("add_value", (JSC.ClassMethodCb) add_value, typeof (JSC.Value));
          klass.add_method ("close", (JSC.ClassMethodCb) close, typeof (JSC.Value));
          klass.add_method ("open", (JSC.ClassMethodCb) open, typeof (JSC.Value));

          _g_object_set_qdata (context, KLASS_QUARK, klass);
        return klass;
        }
    }
}