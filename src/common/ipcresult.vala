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

  namespace IpcResult
    {

      public static GLib.Variant pack_error (GLib.Error error)
        {

          GLib.Variant children [] = {

            new GLib.Variant.string (GLib.DBusError.encode_gerror (error)),
            new GLib.Variant.string (error.message),
          };
        return pack_value (null, new GLib.Variant.tuple (children));
        }

      public static GLib.Variant pack_value (GLib.Variant? value, GLib.Variant? error = null)
        {

          unowned string type = null == value ? "b" : null;

          GLib.Variant children [] = {

            new GLib.Variant.maybe ((GLib.VariantType) "(ss)", null),
            new GLib.Variant.maybe ((GLib.VariantType) type, value),
          };
        return new GLib.Variant.tuple (children);
        }

      public static GLib.Variant unpack (GLib.Variant pack) throws GLib.Error
        {

          if (! pack.check_format_string ("(m(ss)m*)", true))
            throw new GLib.IOError.INVALID_ARGUMENT ("invalid IpcResult pack");

          GLib.Variant item;

          if (null != (item = pack.get_child_value (0).get_maybe ()))
            {

              var dbus_error_name = item.get_child_value (0).get_string ();
              var dbus_error_message = item.get_child_value (1).get_string ();

              throw GLib.DBusError.new_for_dbus_error (dbus_error_name, dbus_error_message);
            }

          if (null != (item = pack.get_child_value (1).get_maybe ()))

            return item;
          else
            throw new GLib.IOError.INVALID_ARGUMENT ("invalid IpcResult pack");
        }
    }
}