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

namespace Wakit.Host
{

  public sealed class Runner: GLib.Object
    {

      public signal void configure_application (Wakit.Host.Application application);
      public signal void configure_capture (Configuration.Config config);

      public int run ([CCode (array_length_cname = "argc", array_length_pos = 0.9, array_length_type = "int")] string[] argv)
        {

          try
            { return run_check (argv); }

          catch (GLib.OptionError error)
            { printerr ("%s\n", error.message); }

          catch (GLib.Error error)
            { GLib.critical ("Wakit.Host.Runner.run()!: %s: %u: %s",
                error.domain.to_string (), error.code, error.message); }
        return 1;
        }

      private int run_check ([CCode (array_length_cname = "argc", array_length_pos = 0.9, array_length_type = "int")] string[] argv) throws GLib.Error
        {

          var args = CommandLine.ensure_argv (ref argv);
          var config = Configuration.capture (ref argv);

          configure_capture (config);

          var application = new Wakit.Host.Application (config);

          configure_application (application);

          var result = application.run (argv);
          _g_strfreev ((owned) args);
        return result;
        }

      [CCode (cheader_filename = "glib.h", cname = "g_strfreev")]
      extern static void _g_strfreev ([CCode (array_length = false, array_null_terminated = true)] owned string[] strv);
    }
}