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
      private GLib.MainLoop _main_loop = null;
      private Transport.Server? _transport_server = null;

      public Application ()
        {

          _context = new GLib.OptionContext ();

          _context.set_help_enabled (true);
          _context.set_ignore_unknown_options (false);
          _context.set_strict_posix (false);
          _context.set_translation_domain ("en_US");

          GLib.OptionEntry entries [] = {

            { "config", 'c', 0, GLib.OptionArg.FILENAME, ref _config, null, null },
            (GLib.OptionEntry) GLib.OptionEntry.NULL,
          };

          _context.add_main_entries (entries, "en_US");
        }

      static int main (string[] argv)
        {

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

              run_async.begin (argv_, (o, res) =>
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

      private string generate_cookie (Configuration configuration)
        {

          /* TODO: cryptographically secure cookie */
          var checksum_type = GLib.ChecksumType.SHA512;
          var checksum = new GLib.Checksum (checksum_type);

          for (int i = 0; i < GLib.Random.int_range (10, 20); ++i)
            {
              double bit = GLib.Random.next_double ();
              checksum.update ((uchar[]) &bit, sizeof (double));
            }
        return checksum.get_string ();
        }

      private async int run_async (string[] args) throws GLib.Error
        {

          Json.Parser parser;
          GLib.InputStream stream;

          if (GLib.str_equal ("-", _config))

            stream = StandardFiles.open_stdin ();
          else
            stream = yield File.new_for_commandline_arg (_config).read_async (GLib.Priority.HIGH);

          yield (parser = new Json.Parser ()).load_from_stream_async (stream);

          Configuration configuration = _json_gobject_deserialize<Configuration> (parser.get_root ());
          string cookie = generate_cookie (configuration);

          _transport_server = yield open_transport (configuration);
          _bus_server = new Bus.Server (_transport_server.guid);

          _transport_server.start ();
          _transport_server.incoming.connect (on_incoming);

          print ("%s,cookie=%s\n", _transport_server.address, cookie);
        return 0;
        }

      private bool on_incoming (GLib.DBusConnection connection)
        {

          _bus_server.add_client (connection);
        return true;
        }

      private bool on_sigint ()
        {

          _transport_server.stop ();
          _bus_server.reap_all ();
          _main_loop.quit ();

        return GLib.Source.REMOVE;
        }

      private async Transport.Server open_transport (Configuration configuration) throws GLib.Error
        {

          GLib.Error? last_error = null;

          foreach (unowned var address in configuration.addresses)
            {

              try
                { return yield new Transport.Server.async (address); }

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
        throw last_error ?? new GLib.IOError.INVALID_ARGUMENT ("no transport address provided");
        }
    }
}