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

namespace Wakit.Host.Module
{

  public sealed class Watcher: GLib.Object, GLib.AsyncInitable
    {

      public Arguments arguments { get; construct; }
      public string bus_name { get; construct set; default = null; }
      public string executable { get; construct set; }
      public uint kill_timeout { get; construct; default = 600; }

      private Process.Watcher? _watcher = null;

      [HasEmitter]
      public signal void crashed (GLib.Error? error);

      public async string boot_async (int io_priority, GLib.Cancellable? cancellable) throws GLib.Error
          requires (null == _watcher)
        {

          unowned var flag1 = GLib.SubprocessFlags.STDIN_PIPE;
          unowned var flag2 = GLib.SubprocessFlags.STDOUT_PIPE;
          unowned var flags = flag1 | flag2;
          var argv = new string[] { _executable };

          var launcher = new GLib.SubprocessLauncher (flags);
          Process.Impl.setup_launcher (launcher);

          GLib.Subprocess subprocess = launcher.spawnv (argv);

          try
            { return yield wait_ready (subprocess, io_priority, cancellable); }
          catch (GLib.Error error)
            { yield Process.terminate_async (subprocess, _kill_timeout);
              throw (owned) error; }
        }

      public async bool init_async (int io_priority, GLib.Cancellable? cancellable) throws GLib.Error
        {

          bus_name = yield boot_async (io_priority, cancellable);
        return true;
        }

      public async bool quit_async (uint timeout) throws GLib.Error
        {

          var watcher = _watcher;
          _watcher = null;

          if (null != watcher)
            yield watcher.terminate (timeout);

        return true;
        }

      private async bool send_arguments (GLib.OutputStream stream, int io_priority, GLib.Cancellable? cancellable) throws GLib.Error
        {

          var generator = new Json.Generator ();

          generator.pretty = false;
          generator.root = Json.gobject_serialize (arguments);

          size_t length, written;
          string data = generator.to_data (out length);

          uint8[] buffer = (uint8[]) (void*) (owned) data;
          buffer.length = (int) length;

          yield stream.write_all_async (buffer, io_priority, cancellable, out written);
          yield stream.flush_async (io_priority, cancellable);

        return length == written;
        }

      private async string wait_ready (GLib.Subprocess subprocess, int io_priority, GLib.Cancellable? cancellable) throws GLib.Error
        {

          var stdin = subprocess.get_stdin_pipe ();

          yield send_arguments (stdin, io_priority, cancellable);
          yield stdin.close_async (io_priority, cancellable);

          var stdout = new GLib.DataInputStream (subprocess.get_stdout_pipe ());
          var unique_name = yield stdout.read_line_async (io_priority, cancellable);

          if (unlikely (null == unique_name || false == GLib.DBus.is_unique_name (unique_name)))
            throw new GLib.IOError.INVALID_DATA (_ ("bad dbus address"));

        return unique_name;
        }
    }
}