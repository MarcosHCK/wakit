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

#if DEVELOP
      public const string DEFAULT_CONFIG = Config.SOURCE_DIR + "/daemon.conf";
      public const string DEFAULT_EXECUTABLE = Config.BUILD_DIR + "/wakit-appbus";
#else // DEVELOP
      public const string DEFAULT_CONFIG = Config.DATA_DIR + "/daemon.conf";
      public const string DEFAULT_EXECUTABLE = Config.LIBEXEC_DIR + "/wakit-appbus";
#endif // DEVELOP

      public string address { get; private set; }
      public uint cooldown { get; construct set; default = 500; }
      public string config { get { return _config; } set { _config = value; } }
      public string executable { get { return _executable; } set { _executable = value; } }
      public uint kill_timeout { get; construct set; default = 1000; }
      public uint launch_timeout { get; construct set; default = 1000; }

      private string _config = DEFAULT_CONFIG;
      private GLib.Cancellable _cancellable = new GLib.Cancellable ();
      private string _executable = "dbus-daemon";
      private bool _quitting = true;
      private uint _tries = 0;
      private Process.Watcher? _watcher = null;

      public signal void connected (GLib.DBusConnection connection);
      public signal void crashed (uint tries, GLib.Error error);

      private async GLib.DBusConnection launch (GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          if (null != _watcher)
            yield _watcher.terminate (kill_timeout, cancellable);

          _watcher = null;

          var cancellable2 = new Utility.TimeoutCancellable (launch_timeout, cancellable);
          var connection = (GLib.DBusConnection) yield launch_spawn (cancellable2);

        return connection;
        }

      private async GLib.DBusConnection launch_reach (GLib.Subprocess subprocess, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          var stdout = new GLib.DataInputStream (subprocess.get_stdout_pipe ());
          var address = (string?) yield stdout.read_line_async (GLib.Priority.DEFAULT, cancellable);

          if (unlikely (null == address || false == GLib.DBus.is_address (address)))
            throw new GLib.IOError.INVALID_DATA ("bad dbus address");

          unowned var flag1 = GLib.DBusConnectionFlags.AUTHENTICATION_CLIENT;
          unowned var flag2 = DBusConnectionFlags.MESSAGE_BUS_CONNECTION;
          unowned var flags = flag1 | flag2;

          var connection = yield new GLib.DBusConnection.for_address (address, flags, null, cancellable);

          connection.exit_on_close = false;
        return connection;
        }

      private async GLib.DBusConnection launch_spawn (GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          unowned var flag1 = GLib.SubprocessFlags.STDOUT_PIPE;
          unowned var flag2 = GLib.SubprocessFlags.STDIN_PIPE;
          unowned var flags = flag1 | flag2;
          var argv = new string[] { _executable, "--config-file", _config, "--nofork", "--print-address" };

          var launcher = new GLib.SubprocessLauncher (flags);
          Process.Impl.setup_launcher (launcher);

          GLib.DBusConnection connection;
          var subprocess = launcher.spawnv (argv);

          try
            { connection = yield launch_reach (subprocess, cancellable);
              (_watcher = new Process.Watcher (subprocess)).terminated.connect (process_crash); }
          catch (GLib.Error error)
            { yield Process.terminate_async (subprocess, _kill_timeout);
              throw (owned) error; }
        return connection;
        }

      public void quit ()
        {

          quit_async.begin ();
        }

      public async void quit_async () requires (false == _quitting)
        {

          var watcher = _watcher;

          _quitting = true;
          _cancellable.cancel ();
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

      private void process_crash (GLib.Error? error)
        {

          if (null == error)
            {
              restart_schedule (this);
              return;
            }

          crashed (++_tries, error);
          restart_schedule (this);
        }

      public void restart () requires (true == _quitting)
        {

          _quitting = false;
          _cancellable = new GLib.Cancellable ();

          restart_internal ();
        }

      private void restart_finished (GLib.AsyncResult res)
        {

          try
            {
              connected (launch.end (res));
              _tries = 0;
            }
          catch (GLib.Error error)
            { process_crash (error); }
        }

      private void restart_internal ()
        {

          launch.begin (_cancellable, (o, res) =>
            {
              ((AppBus.Watcher) o).restart_finished (res);
            });
        }

      private static void restart_schedule (AppBus.Watcher self)
        {

          if (self._quitting)
            return;

          var source = new GLib.TimeoutSource (self._cooldown);

          source.set_callback (() => { self.restart_internal ();
                                            return GLib.Source.REMOVE; });

          source.attach (GLib.MainContext.ref_thread_default ());
        }
    }
}