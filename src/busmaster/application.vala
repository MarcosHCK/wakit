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

namespace Wakit.Busmaster
{

  class Application
    {

      private unowned string _config = "-";
      private GLib.OptionContext _context;

      private Bus.Server? _bus_server = null;
      private AppBus.AuthenticationServer _auth_server = null;
      private AppBus.Cookie? _cookie = null;
      private GLib.MainLoop _main_loop = null;
      private bool _nofork = false;
      private bool _print_address = false;
      private uint _timeout = 1000;
      private Transport.Server? _transport_server = null;

      public Application ()
        {

          _context = new GLib.OptionContext ();

          _context.set_help_enabled (true);
          _context.set_ignore_unknown_options (false);
          _context.set_strict_posix (false);
          _context.set_translation_domain (Wakit.BuildConfig.GETTEXT_PACKAGE);

          GLib.OptionEntry entries [] = {

            { "config-file", 'c', 0, GLib.OptionArg.FILENAME, ref _config, null, null },
            { "nofork", 0, 0, GLib.OptionArg.NONE, ref _nofork, null, null },
            { "print-address", 0, 0, GLib.OptionArg.NONE, ref _print_address, null, null },
            (GLib.OptionEntry) GLib.OptionEntry.NULL,
          };

          _context.add_main_entries (entries, Wakit.BuildConfig.GETTEXT_PACKAGE);
        }

      static int main (string[] argv)
        {

          I18n.app_setup ();
        return (new Application ()).run (argv);
        }

      private int run (string[] argv)
        {

          var argv_ = argv;

          try
            {

              _context.parse_strv (ref argv_);

              var main_context = GLib.MainContext.default ();
              var main_loop = new GLib.MainLoop (main_context, false);

              GLib.Error error = null;
              int result = 0;

              _main_loop = main_loop;
              sigint_source_add (main_context, on_sigint);

              run_async.begin (argv_, null, (o, res) =>
                {

                  try
                    { result = ((Application) o).run_async.end (res); }
                  catch (GLib.Error e)
                    { error = (owned) e; main_loop.quit (); }
                });

              main_loop.run ();

              if (unlikely (null != error))
                throw (owned) error;

              for (GLib.MainContext context = _main_loop.get_context (); context.pending ();)
                context.iteration (false);

            return result;
            }
          catch (GLib.Error error)
            {
              unowned uint code = error.code;
              unowned string domain = error.domain.to_string ();
              unowned string message = error.message.to_string ();

              printerr ("%s: %u: %s", domain, code, message);
            }
        return 1;
        }

      [CCode (cheader_filename = "json-glib/json-glib.h",
              cname = "json_gobject_deserialize",
              simple_generics = true)]
      extern static T _json_gobject_deserialize<T> ([CCode (pos = 2.1)] Json.Node node, GLib.Type g_type = typeof (T));

      [CCode (cheader_filename = "busmaster/application.c")]
      extern static void sigint_source_add (GLib.MainContext context, owned GLib.SourceFunc func);

      private async int run_async (string[] args, GLib.Cancellable? cancellable) throws GLib.Error
        {

          Json.Parser parser;

          var file = GLib.File.new_for_commandline_arg (_config);
          var stream = yield file.read_async (GLib.Priority.HIGH, cancellable);

          yield (parser = new Json.Parser ()).load_from_stream_async (stream, cancellable);

          Configuration configuration = _json_gobject_deserialize<Configuration> (parser.get_root ());

          if (false == configuration.disable_client_cookie)
            {

              _cookie = new AppBus.Cookie.random ();
              _auth_server = new AppBus.AuthenticationServer (_cookie);
            }

          _timeout = configuration.timeout;

          _transport_server = yield open_transport (configuration, cancellable);
          _bus_server = new Bus.Server (GLib.DBus.generate_guid ());

          _transport_server.start ();
          _transport_server.incoming.connect (on_incoming);

          if (_print_address)
            print_address (_transport_server.address, _bus_server.guid, _cookie?.to_string ());

        return 0;
        }

      private bool on_incoming (GLib.IOStream stream)
        {

          unowned var auth_server = _auth_server;
          unowned var guid = _bus_server.guid;
          unowned var timeout = _timeout;

          AppBus.connect_server.begin (stream, guid, auth_server, timeout, null, on_incoming_complete);
        return true;
        }

      private void on_incoming_complete (GLib.Object? source_object, GLib.AsyncResult result)
        {

          try
            { _bus_server.add_client (AppBus.connect_server.end (result)); }
          catch (GLib.Error error)
            { GLib.warning ("Application:incoming ()!: %s: %u: %s",
                error.domain.to_string (), error.code, error.message); }
        }

      private bool on_sigint ()
        {

          _transport_server.stop ();
          _bus_server.reap_all ();
          _main_loop.quit ();

        return GLib.Source.REMOVE;
        }

      private async Transport.Server open_transport (Configuration configuration, GLib.Cancellable? cancellable) throws GLib.Error
        {

          GLib.Error? last_error = null;

          foreach (unowned var address in configuration.addresses)
            {

              try
                { return yield new Transport.Server.async (address, GLib.Priority.DEFAULT, cancellable); }

              catch (GLib.Error error)
                {
                  if (unlikely (null != last_error))
                { unowned uint code = last_error.code;
                  unowned string domain = last_error.domain.to_string ();
                  unowned string message = last_error.message.to_string ();

                  GLib.warning ("Transport.Server ()!: %s: %u: %s", domain, code, message); }
                  last_error = (owned) error;
                }
            }
        throw last_error ?? new GLib.IOError.INVALID_ARGUMENT (_ ("no transport address provided"));
        }

      static void print_address (string address, string guid, string? cookie)
        {

          if (null == cookie)

            print ("%s,guid=%s\n", address, guid);
          else
            print ("%s,guid=%s,x-cookie=%s\n", address, guid, cookie);
        }
    }
}
