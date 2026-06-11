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

  /**
   * Keep well-known bus things in sync with host/module/modulehost.vala
   */

  internal sealed class BridgeModule: GLib.Object, GLib.AsyncInitable
    {

      public const string OBJECT_PATH = "/org/hck/wakit/Host/Module";

      public string bus_name { get; construct; }
      public GLib.DBusConnection connection { get; construct; }

      private GLib.Regex _camel_case_tokens = create_camel_case_tokens ("[\\.-]", GLib.RegexCompileFlags.OPTIMIZE);
      private string _client_prefix;
      private string _server_prefix;

      public async BridgeModule (string bus_name, GLib.DBusConnection connection, int io_priority, GLib.Cancellable? cancellable) throws GLib.Error
        {

          Object (bus_name: bus_name, connection: connection);
          yield init_async (io_priority, cancellable);
        }

      string build_name (string original)
        {

          unowned string original_ = ! original.has_prefix (_server_prefix)
                                   ? original : original.offset (_server_prefix.length);

          var builder = camel_case_builder (original_);
          builder.prepend (_client_prefix);

        return builder.free_and_steal ();
        }

      async string call_get_string_method (string method_name, GLib.Cancellable? cancellable) throws GLib.Error
        {

          const string interface_name = "org.hck.wakit.HostApplication";
          const string object_path = OBJECT_PATH;
          const int timeout_msec = -1;
          unowned var flags = GLib.DBusCallFlags.NO_AUTO_START;
          unowned var parameters = (GLib.Variant?) null;
          unowned var reply_type = (GLib.VariantType) "(s)";

          var reply = yield connection.call (bus_name, object_path, interface_name, method_name, parameters, reply_type, flags, timeout_msec, cancellable);

        return reply.get_child_value (0).get_string ();
        }

      StringBuilder camel_case_builder (string value)
        {

          var builder = new StringBuilder.sized (value.length);
          int piece_length = 0;

          foreach (unowned var piece in _camel_case_tokens.split (value)) if (0 < (piece_length = piece.length))
            {

              builder.append_c (piece[0].toupper ());
              builder.append_len (piece.offset (1), piece_length - 1);
            }
        return (owned) builder;
        }

      public async BridgeModuleExport create_export (DBusService dbus_service, string interface_name, string object_path, GLib.Cancellable? cancellable) throws GLib.Error
        {

          unowned GLib.DBusProxyFlags flags = GLib.DBusProxyFlags.NONE;
          unowned GLib.DBusInterfaceInfo info = yield dbus_service.lookup_info (bus_name, interface_name, object_path, cancellable);

          var dbus_proxy = yield new GLib.DBusProxy (_connection, flags, info, bus_name, object_path, interface_name, cancellable);
          var type_name = build_name (interface_name);

        return BridgeModuleExport (dbus_proxy, type_name);
        }

      static GLib.Regex create_camel_case_tokens (string pattern, RegexCompileFlags compile_options = 0, RegexMatchFlags match_options = 0)
        {

          try
            { return new GLib.Regex (pattern, compile_options, match_options); }
          catch (GLib.Error error)
            { GLib.error ("Wakit.Binding.BridgeModule.create_camel_case_tokens()!: %s: %u: %s", error.domain.to_string (), error.code, error.message); }
        }

      bool finish_init (owned string client_prefix, owned string server_prefix)
        {

          _client_prefix = (owned) client_prefix;
          _server_prefix = (owned) server_prefix;
        return true;
        }

      public async override bool init_async (int io_priority, GLib.Cancellable? cancellable) throws GLib.Error
        {

          var name = yield call_get_string_method ("get_name", cancellable);
          var name_builder = camel_case_builder (name);
          var type_prefix = yield call_get_string_method ("get_type_prefix", cancellable);

        return finish_init (name_builder.free_and_steal (), (owned) type_prefix);
        }
    }
}