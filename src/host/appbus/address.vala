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

namespace Wakit.AppBus
{

  [Compact (opaque = false)] public class Address
    {

      public string _address;
      public AddressOption[] _options;
      public AddressString _transport;

      public AddressOption[] options { get { return _options; } }
      public string transport { owned get { return _transport.get_value (); } }

      public Address (string address) throws GLib.Error
        {

          var ar = new Array<AddressOption> ();

          unowned var tl = (uint) 0;
          unowned var tr = (string) parse_ (_address = address, out tl, ar);

          _options = ar.steal ();
          _transport = AddressString (tr, tl);
        }

      public unowned AddressOption? lookup_option (string key)
        {

          int l = 0;
          int r = _options.length - 1;

          while (r >= l)
            {

              var m = (int) Math.floor ((l + r) >> 1);
              var f = GLib.Memory.cmp (key, _options [m]._key.value, _options [m]._key.length);

              if (f > 0) l = m + 1;
              else if (f < 0) r = m - 1;
              else return _options [m];
            }
        return null;
        }

      private extern delegate void ForeachOption (string key, uint key_length,
                                                  string value, uint value_length);

      [CCode (cheader_filename = "host/appbus/address.h")]
      private extern static unowned string parse (string address, out uint length, ForeachOption foreach_option) throws GLib.Error;

      private static unowned string parse_ (string address, out uint length, Array<AddressOption> options) throws GLib.Error
        {

          return parse (address, out length, (k, kl, v, vl) =>
            {

              var key = AddressString (k, kl);
              var value = AddressString (v, vl);

              options.append_val (AddressOption (key, value));
            });
        }
    }
}