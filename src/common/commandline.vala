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

namespace Wakit.CommandLine
{

  [CCode (cheader_filename = "common/commandline.h",
          array_length = false, array_null_terminated = true)]
  public extern static string[] ensure_argv ([CCode (array_length_cname = "argc", array_length_pos = 0.9, array_length_type = "int")] ref unowned string[] argv);

  [CCode (cheader_filename = "common/commandline.h")]
  public extern static unowned GLib.InputStream get_stdin ();

  [CCode (cheader_filename = "common/commandline.h")]
  public extern static unowned GLib.OutputStream get_stdout ();

  [CCode (cheader_filename = "common/commandline.h", cname = "GSource"), Compact] public extern class InterruptSource: GLib.Source
    {

      public extern InterruptSource ();
      protected override extern bool dispatch (SourceFunc? _callback);
    }
}