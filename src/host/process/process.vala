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

  [CCode (cheader_filename = "host/process/impl.h")] namespace Impl
    {

      public extern void setup_launcher (GLib.SubprocessLauncher launcher);
      public extern void terminate_gracefully (GLib.Subprocess subprocess);
      public extern async void terminate_gracefully_and_wait (GLib.Subprocess subprocess, GLib.Cancellable? cancellable = null) throws GLib.Error;
    }

  public static async void terminate_async (GLib.Subprocess subprocess, uint timeout = 1000, GLib.Cancellable? cancellable = null) throws GLib.Error
    {

      var source = new GLib.TimeoutSource (timeout);

      source.set_callback (() => { subprocess.force_exit ();
                                         return GLib.Source.REMOVE; });

      source.attach (GLib.MainContext.ref_thread_default ());

      yield Process.Impl.terminate_gracefully_and_wait (subprocess, cancellable);
      source.destroy ();
    }
}