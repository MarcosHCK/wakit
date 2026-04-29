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

namespace Wakit.Browser
{

  public sealed class DragController: GLib.Object
    {

      public const string ATTRIBUTE = "data-wakit-drag-area";
      public const uint DEFAULT_DRAG_DELAY = 50;
      public const double MIN_OFFSET = 10;

      private GLib.Cancellable? _cancellable = null;

      public Gtk.GestureDrag controller { get; }
      public bool drag { get; set; }
      public uint drag_delay { get; construct; }
      public WebKit.WebView web_view { get; construct; }

      public DragController (WebKit.WebView web_view, uint drag_delay = DEFAULT_DRAG_DELAY)
        {

          Object (drag_delay: drag_delay, web_view: web_view);
        }

      public override void constructed ()
        {

          _controller = new Gtk.GestureDrag ();

          _controller.drag_begin.connect (on_drag_begin);
          _controller.drag_end.connect (on_drag_end);
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

      private void on_drag_begin (double x, double y)
        {

          _cancellable = new GLib.Cancellable ();
          _on_drag_begin_async.begin (x, y, _cancellable, (o, res) =>
            ((DragController) o).on_drag_begin_complete (res));
        }

      private void on_drag_begin_complete (GLib.AsyncResult result)
        {

          try
            {
              _cancellable = null;

              if (_on_drag_begin_async.end (result))
                _drag = true;
            }
          catch (GLib.IOError.CANCELLED error)
            { }
          catch (GLib.Error error)
            {

              warning ("Wakit.Browser.DragController.on_drag_begin ()!: %s: %u: %s",
                error.domain.to_string (), error.code, error.message);
            }
        }

      private void on_drag_end (double x, double y)
        {

          _cancellable?.cancel ();
          _drag = false;
        }

      private void on_drag_update (double dx, double dy)
        {

          double x = 0, y = 0;

          if (!_drag || !_controller.get_start_point (out x, out y) || distance (dx, dy) < MIN_OFFSET)
            return;

          unowned var button = (int) _controller.get_current_button ();
          unowned var event = _controller.get_current_event ();
          unowned var device = _controller.get_current_event_device ();

          get_toplevel ()?.begin_move (device, button, x, y, event?.get_time () ?? 0);
        }

      [CCode (cheader_filename = "glib.h", cname = "G_USEC_PER_SEC")]
      extern const uint _G_USEC_PER_SEC;

      const uint _G_USEC_PER_MSEC = _G_USEC_PER_SEC / 1000;

      const string TEST_TEMPLATE = "!(document.elementsFromPoint (%f, %f))
                                              .every (e => !e.hasAttribute ('"
                                 + ATTRIBUTE + "'))";

      async bool _on_drag_begin_async (double x, double y, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          var scheme = GLib.Uri.parse_scheme (_web_view.get_uri ());

          if ("app" != scheme)
            return false;

          yield async_delay (_drag_delay, GLib.Priority.DEFAULT, cancellable);

          string code = TEST_TEMPLATE.printf (x, y);

          JSC.Value result = yield _web_view.evaluate_javascript (code, -1, null,
            "wakit:///host/browser/drag_controller/hit_test.js", cancellable);

        return result.to_boolean ();
        }
    }
}