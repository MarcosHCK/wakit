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

namespace Wakit.Process
{

  public sealed class Watcher: GLib.Object
    {

      private GLib.Cancellable _cancellable;
      public bool died { get; private set; default = false; }
      public GLib.Subprocess subprocess { get; construct; }

      ~Watcher ()
        {
          _cancellable.cancel ();
        }

      public Watcher (GLib.Subprocess subprocess)
        {

          Object (subprocess: subprocess);
        }

      public override void constructed ()
        {

          base.constructed ();
          constructed_static (this);
        }

      private static void constructed_static (Watcher watcher)
        {

          unowned var cancellable = watcher._cancellable;
          unowned var subprocess = watcher._subprocess;
          var @ref = GLib.WeakRef (watcher);

          subprocess.wait_check_async.begin (cancellable, (o, res) =>
            {

              Watcher? self;

              if (unlikely (null != (self = (Watcher?) @ref.get ())))
                self.on_wait_check_async_complete (res);
            });
        }

      private void on_wait_check_async_complete (GLib.AsyncResult res)
        {

          try
            { subprocess.wait_check_async.end (res);
              terminated (null); }
          catch (GLib.IOError.CANCELLED error)
            { }
          catch (GLib.Error error)
            { terminated (error); }

          _died = true;
        }

      public async void terminate (uint timeout = 1000, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          if (true == _died)
            return;

          _cancellable.cancel ();
          yield Process.terminate_async (_subprocess, timeout, cancellable);
        }

      [CCode (cname = "WAKIT_PROCESS_WATCHER_GET_CLASS (self)->terminated")]
      extern const uintptr terminated_actv;

      [CCode (cname = "wakit_process_watcher_real_terminated")]
      extern const uintptr terminated_real;

      [CCode (cname = "wakit_process_watcher_signals[WAKIT_PROCESS_WATCHER_TERMINATED_SIGNAL]")]
      extern const uint terminated_sid;

      [HasEmitter]
      [Signal (run = "last")]
      public virtual signal void terminated (GLib.Error? error)
        {

          if (! GLib.Signal.has_handler_pending (this, terminated_sid, 0, true)
             && terminated_actv == terminated_real)
            {

              if (null == error)

                warning ("watched program was terminated");
              else
                warning ("watched program crashed: %s: %u: %s", error.domain.to_string (), error.code, error.message);
            }
        }
    }
}