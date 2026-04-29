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

  public sealed class WebViewBinding: GLib.Object
    {

      private ulong _close_sid = 0;
      private ulong _notify_state_sid = 0;
      private ulong _realize_sid = 0;
      private ulong _unrealize_sid = 0;

      public bool maximized
        {
          get { return Gdk.ToplevelState.MAXIMIZED in (surface as Gdk.Toplevel)?.state; }
          set { var toplevel = (surface as Gdk.Toplevel); if (null != toplevel)
                  _set_maximized (toplevel, value);
        } }

      public bool minimized
        {
          get { return Gdk.ToplevelState.MINIMIZED in (surface as Gdk.Toplevel)?.state; }
          set { var toplevel = (surface as Gdk.Toplevel); if (null != toplevel)
                  _set_minimized (toplevel, value, maximized);
        } }

      public Gdk.Surface surface { get { return window?.get_native ()?.get_surface (); } }

      public unowned Wakit.IWebView web_view { get; private set; }
      public unowned Gtk.Window window { get; private set; }

      ~WebViewBinding ()
        {

          if (null != _web_view)
            on_destroy_web_view_things ();

          if (null != _window)
            on_destroy_window_things ();
        }

      internal WebViewBinding (Wakit.IWebView web_view, Gtk.Window window)
        {

          _window = window;
          _web_view = web_view;

          unowned GLib.BindingFlags flag1 = GLib.BindingFlags.BIDIRECTIONAL;
          unowned GLib.BindingFlags flags = flag1;

          bind_property ("maximized", web_view, "maximized", flags);
          bind_property ("minimized", web_view, "minimized", flags);

          _close_sid = _g_signal_connect_data (web_view, "close", (GLib.Callback) on_close, this);

          _realize_sid = GLib.Signal.connect_swapped (window, "realize", (GLib.Callback) on_window_realize, this);
          _unrealize_sid = GLib.Signal.connect_swapped (window, "unrealize", (GLib.Callback) on_window_unrealize, this);

          _g_object_weak_ref (web_view, on_destroy, this);
          _g_object_weak_ref (window, on_destroy, this);
        }

      static void _set_maximized (Gdk.Toplevel toplevel, bool value)
        {

          var layout = new Gdk.ToplevelLayout ();

          layout.set_resizable (true);
          layout.set_maximized (value);
          toplevel.present (layout);
        }

      static void _set_minimized (Gdk.Toplevel toplevel, bool value, bool maximized)
        {

          if (value)
            { toplevel.minimize (); return; }

          var layout = new Gdk.ToplevelLayout ();

          layout.set_resizable (true);
          layout.set_maximized (maximized);
          toplevel.present (layout);
        }

      private void on_close ()
        {

          _window.close ();
        }

      static void on_destroy (WebViewBinding w, GLib.Object object)
        {

          if ((void*) object == (void*) w._web_view)
            w._web_view = null;

          if ((void*) object == (void*) w._window)
            w._window = null;

          w.unref ();
        }

      private void on_destroy_web_view_things ()
        {

          _web_view.disconnect (_close_sid);

          _g_object_weak_unref (_web_view, on_destroy, this);
        }

      private void on_destroy_window_things ()
        {

          _window.disconnect (_realize_sid);
          _window.disconnect (_unrealize_sid);

          _g_object_weak_unref (_window, on_destroy, this);
        }

      private void on_notify_state ()
        {

          notify_property ("maximized");
          notify_property ("minimized");
        }

      private void on_window_realize ()
        {

          Gdk.Toplevel toplevel;

          if (null == (toplevel = window?.get_surface () as Gdk.Toplevel))
            return;

          _notify_state_sid = toplevel.notify ["state"].connect (on_notify_state);
          on_notify_state ();
        }

      private void on_window_unrealize ()
        {

          Gdk.Toplevel toplevel;

          if (null == (toplevel = window?.get_surface () as Gdk.Toplevel))
            return;

          if (_notify_state_sid > 0)
            toplevel.disconnect (_notify_state_sid);

          _notify_state_sid = 0;
        }

      [CCode (cheader_filename = "glib-object.h",
                         cname = "GWeakNotify",
                    has_target = false,
                         scope = "forever")]
      extern delegate void WeakNotify (WebViewBinding binding, GLib.Object object);

      [CCode (cheader_filename = "glib-object.h",
                         cname = "g_object_weak_ref")]
      extern static void _g_object_weak_ref (GLib.Object object, WeakNotify notify_func, void* data);

      [CCode (cheader_filename = "glib-object.h",
                         cname = "g_object_weak_unref")]
      extern static void _g_object_weak_unref (GLib.Object object, WeakNotify notify_func, void* data);

      [CCode (cheader_filename = "glib-object.h",
                         cname = "g_signal_connect_data")]
      extern static ulong _g_signal_connect_data (GLib.Object widget, string n, GLib.Callback callback, void* data,
                                                                                GLib.ClosureNotify? notify = null,
                                                                                GLib.ConnectFlags flags = GLib.ConnectFlags.SWAPPED);
    }
}