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

  public sealed class Watcher: GLib.Object
    {

      [CCode (cname = "BUSMASTER_PATH")]
      extern const string BUSMASTER_PATH;
#if DEVELOP
      private const string DEFAULT_CONFIG = Config.SOURCE_DIR + "/daemon.json";
      private const string DEFAULT_EXECUTABLE = BUSMASTER_PATH;
#else // DEVELOP
      private const string DEFAULT_CONFIG = Config.DATA_DIR + "/daemon.json";
      private const string DEFAULT_EXECUTABLE = Config.LIBEXEC_DIR + "/wakit-busmaster";
#endif // DEVELOP

      public uint cooldown { get; construct set; default = 500; }
      public string config { get { return _config; } set { _config = value; } }
      public string executable { get { return _executable; } set { _executable = value; } }
      public uint kill_timeout { get; construct set; default = 1000; }
      public uint launch_timeout { get; construct set; default = 1000; }

      public string address { get; private set; }
      public GLib.DBusConnection connection { get; private set; }

      private string _config = DEFAULT_CONFIG;
      private string _executable = DEFAULT_EXECUTABLE;
      private Process.Watcher? _watcher = null;

      [HasEmitter]
      public signal void crashed (GLib.Error? error);

      public async bool launch (GLib.Cancellable? cancellable = null) throws GLib.Error requires (null == _watcher)
        {

          var cancellable2 = new TimeoutCancellable (launch_timeout, cancellable);
          var result = (bool) yield launch_spawn (cancellable2);

        return result;
        }

      private async bool launch_reach (GLib.Subprocess subprocess, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          var stdout = new GLib.DataInputStream (subprocess.get_stdout_pipe ());
          var address = (string?) yield stdout.read_line_async (GLib.Priority.DEFAULT, cancellable);

          if (unlikely (null == address || false == GLib.DBus.is_address (address)))
            throw new GLib.IOError.INVALID_DATA ("bad dbus address");

          _address = (owned) address;
          _connection = yield Wakit.AppBus.connect_client (_address, null, cancellable);

        return true;
        }

      private async bool launch_spawn (GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          unowned var flag1 = GLib.SubprocessFlags.STDOUT_PIPE;
          unowned var flag2 = GLib.SubprocessFlags.STDIN_PIPE;
          unowned var flags = flag1 | flag2;
          var argv = new string[] { _executable, "--config-file", _config, "--nofork", "--print-address" };

          var launcher = new GLib.SubprocessLauncher (flags);
          Process.Impl.setup_launcher (launcher);

          bool result;
          GLib.Subprocess subprocess = launcher.spawnv (argv);

          try
            { result = yield launch_reach (subprocess, cancellable);
              (_watcher = new Process.Watcher (subprocess)).terminated.connect (crashed); }
          catch (GLib.Error error)
            { yield Process.terminate_async (subprocess, _kill_timeout);
              throw (owned) error; }
        return result;
        }

      public void quit ()
        {

          quit_async.begin ();
        }

      public async void quit_async ()
        {

          var watcher = _watcher;

          _watcher = null;

          if (null != watcher) try
            {
              yield watcher.terminate (kill_timeout);
            }
          catch (GLib.Error error)
            {

              unowned uint code = error.code;
              unowned string domain = error.domain.to_string ();
              unowned string message = error.message.to_string ();

              warning ("daemon reap failed: %s: %u: %s", domain, code, message);
            }
        }
    }
}