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

  [Compact (opaque = true)] public class WebViewBinding
    {

      private ulong _close_sid = 0;
      private ulong _maximize_sid = 0;
      private ulong _minimize_sid = 0;

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
          unowned GLib.BindingFlags flag2 = GLib.BindingFlags.SYNC_CREATE;
          unowned GLib.BindingFlags flags = flag1 | flag2;

          _close_sid = _g_signal_connect_data (web_view, "close", (GLib.Callback) on_close, this);
          _maximize_sid = _g_signal_connect_data (web_view, "maximize", (GLib.Callback) on_maximize, this);
          _minimize_sid = _g_signal_connect_data (web_view, "minimize", (GLib.Callback) on_minimize, this);

          window.bind_property ("maximized", web_view, "maximized", flags);

          _g_object_weak_ref (web_view, on_destroy, this);
          _g_object_weak_ref (window, on_destroy, this);
        }

      extern void free ();

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

          w.free ();
        }

      private void on_destroy_web_view_things ()
        {

          _web_view.disconnect (_close_sid);
          _web_view.disconnect (_maximize_sid);
          _web_view.disconnect (_minimize_sid);

          _g_object_weak_unref (_web_view, on_destroy, this);
        }

      private void on_destroy_window_things ()
        {

          _g_object_weak_unref (_window, on_destroy, this);
        }

      private void on_maximize (bool @set, bool value)
        {

          Gtk.Window window = _window;

          if (@set ? value : !( Gdk.ToplevelState.MAXIMIZED in (window.get_native ()?.get_surface () as Gdk.Toplevel)?.state))
            window.maximize (); else window.unmaximize ();
        }

      private void on_minimize (bool @set, bool value)
        {

          Gtk.Window window = _window;

          if (@set ? value : !( Gdk.ToplevelState.MINIMIZED in (window.get_native ()?.get_surface () as Gdk.Toplevel)?.state))
            window.minimize (); else window.unminimize ();
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