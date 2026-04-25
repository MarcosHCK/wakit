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

  [Compact (opaque = true)] public class WidgetBinding
    {

      private unowned ulong _close_sid;
      private unowned GLib.Binding _maximized_binding;

      private GLib.WeakRef _widget;
      private GLib.WeakRef _toplevel;

      public Gtk.Window? toplevel { owned get { return (Gtk.Window?) _toplevel.get (); }
                                  private set { _toplevel.set (value); } }

      public Wakit.Browser.Widget? widget { owned get { return (Wakit.Browser.Widget?) _widget.get (); }
                                          private set { _widget.set (value); } }

      ~WidgetBinding ()
        {

          var toplevel = this.toplevel; if (null != toplevel)
            {
              _maximized_binding.unbind ();
            }

          var widget = this.widget; if (null != widget)
            {
              widget.disconnect (_close_sid);
            }
        }

      public WidgetBinding (Widget widget, Gtk.Window target)
        {

          _toplevel = GLib.WeakRef (target);
          _widget = GLib.WeakRef (widget);

          unowned GLib.BindingFlags flag1 = GLib.BindingFlags.BIDIRECTIONAL;
          unowned GLib.BindingFlags flag2 = GLib.BindingFlags.SYNC_CREATE;
          unowned GLib.BindingFlags flags = flag1 | flag2;
          unowned WidgetBinding self = this;

          _close_sid = _g_signal_connect_data<SignalHandlerVoid0> (widget, "close", b => b.toplevel?.close (), self);

          _maximized_binding = widget.bind_property ("maximized", target, "maximized", flags);
        }

      [CCode (has_target = false,
                   scope = "forever")]
      delegate void SignalHandlerVoid0 (WidgetBinding w);

      [CCode (cheader_filename = "glib-object.h",
                         cname = "g_signal_connect_data",
               simple_generics = true)]
      extern static ulong _g_signal_connect_data<T> (GLib.Object widget, string n, T callback, void* data,
                                                                                   GLib.ClosureNotify? notify = null,
                                                                                   GLib.ConnectFlags flags = GLib.ConnectFlags.SWAPPED);
    }
}