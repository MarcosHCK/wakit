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

namespace Wakit.Gui
{

  public sealed class Dragger: GLib.Object
    {

      const double min_offset = 10;

      public Gtk.GestureDrag controller { get; }
      public bool drag { get; set; }

      public override void constructed ()
        {

          base.constructed ();

          _controller = new Gtk.GestureDrag ();
          _controller.drag_update.connect (on_drag_update);
          _controller.propagation_phase = Gtk.PropagationPhase.CAPTURE;
        }

      static double distance (double dx, double dy)
        {
          return Math.sqrt ((dx * dx) + (dy * dy));
        }

      private Gdk.Toplevel? get_toplevel ()
        {

          unowned var widget = controller.get_widget ();
          unowned var native = widget?.get_native ();
          unowned var surface = native?.get_surface ();

        return ! (surface is Gdk.Toplevel) ? null : (Gdk.Toplevel) surface;
        }

      private void on_drag_update (double dx, double dy)
        {

          double x = 0, y = 0;

          if (!_drag || !_controller.get_start_point (out x, out y) || distance (dx, dy) < min_offset)
            return;

          unowned var button = (int) _controller.get_current_button ();
          unowned var event = _controller.get_current_event ();
          unowned var device = _controller.get_current_event_device ();

          get_toplevel ()?.begin_move (device, button, x, y, event?.get_time () ?? 0);
        }
    }
}