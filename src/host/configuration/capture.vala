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

namespace Wakit.Host.Configuration
{

  static ssize_t bounded_cast (size_t value) throws GLib.Error
    {

      if (value < (size_t) ssize_t.MAX)

        return (ssize_t) value;
      else
        throw new GLib.OptionError.BAD_VALUE ("file is too big");
    }

  public const GLib.OptionEntry CONFIG_ENTRY = { "config", 'c', 0, GLib.OptionArg.FILENAME, null,
    "Configuration file to use (default: wakit.config.json)", "FILE" };

  public static Config capture ([CCode (array_length_cname = "argc", array_length_pos = 0.9)] ref unowned string[] argv) throws GLib.Error
    {

      unowned string config = "wakit.config.json";

      var context = new GLib.OptionContext ();
      var entries = capture_entries ();

      entries [0].arg_data = &config;

      context.add_main_entries (entries, "en_US");
      context.set_help_enabled (false);
      context.set_ignore_unknown_options (true);
      context.parse (ref argv);

    return capture_construct (config);
    }

  private static Config capture_construct (string filename) throws GLib.Error
    {

      var mapped_file = new GLib.MappedFile (filename, false);
      var config_json = mapped_file.get_contents ();
      var json_length = bounded_cast (mapped_file.get_length ());

    return _json_gobject_from_data<Config> ((string) config_json, json_length);
    }

  [CCode (array_null_terminated = true,
          array_length = false)]
  public static unowned GLib.OptionEntry[] capture_entries ()
    {

      const GLib.OptionEntry entries [] = {
        Wakit.Host.Configuration.CONFIG_ENTRY,
        GLib.OptionEntry.NULL,
      };
    return entries;
    }

  [CCode (cheader_filename = "json-glib/json-glib.h", cname = "json_gobject_from_data", simple_generics = true)]
  extern static T _json_gobject_from_data<T> (string data, ssize_t length, [CCode (pos = 0.9)] GLib.Type g_type = typeof (T)) throws GLib.Error;
}