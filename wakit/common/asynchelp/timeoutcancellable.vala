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

namespace Wakit
{

  public sealed class TimeoutCancellable: GLib.Cancellable
    {

      private GLib.Source? _source = null;

      public GLib.Cancellable? inner { construct; }
      public uint timeout { get; construct; }

      ~TimeoutCancellable ()
        {
          _source?.destroy ();
        }

      public TimeoutCancellable (uint timeout, GLib.Cancellable? inner = null)
        {
          Object (inner: inner, timeout: timeout);
        }

      static bool cancel_callback (GLib.Cancellable cancellable)
        {

          cancellable.cancel ();

        return GLib.Source.REMOVE;
        }

      public override void constructed ()
        {

          base.constructed ();
          constructed_static (this);
        }

      static void constructed_static (TimeoutCancellable self)
        {

          unowned var cancellable = (TimeoutCancellable) self;
          unowned var interval = (uint) self._timeout;
          unowned var inner = (GLib.Cancellable?) self._inner;

          var context = GLib.MainContext.ref_thread_default ();

          var source = (self._source = 0 < interval
            ? (GLib.Source) new GLib.TimeoutSource (interval)
            : (GLib.Source) new GLib.CancellableSource (inner));

          if (0 < interval)
            source.add_child_source (new GLib.CancellableSource (inner));

          source.set_callback (() => cancel_callback (cancellable));
          source.attach (context);
        }
    }
}