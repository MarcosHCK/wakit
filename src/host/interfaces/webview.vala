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

  public enum WebViewTerminationReason
    {
      API_CALL,
      CRASH,
      OUT_OF_MEMORY,
    }

  public interface IWebView: Gtk.Widget
    {

      public unowned WebViewBinding bind_window (Gtk.Window window)
        {

          var binding = new WebViewBinding (this, window);
          var collect = (void*) (owned) binding;
        return (WebViewBinding) collect;
        }

      [CCode (cname = "WAKIT_IWEB_VIEW_GET_INTERFACE (self)->close")]
      extern const uintptr close_actv;

      [CCode (cname = "wakit_iweb_view_real_close")]
      extern const uintptr close_real;

      [CCode (cname = "wakit_iweb_view_signals[WAKIT_IWEB_VIEW_CLOSE_SIGNAL]")]
      extern const uint close_sid;

      [HasEmitter, Signal (action = true, run = "first")]
      public virtual signal void close ()
        {

          if (! GLib.Signal.has_handler_pending (this, close_sid, 0, true)
             && close_actv == close_real)
            {

              GLib.warning_once ("Your application does not implement "
                               + "wakit_iweb_view_close() and has no handlers connected "
                               + "to the 'close' signal. It should do one of these.");
            }
        }

      public abstract void open_uri (GLib.File uri, string hint);

      [CCode (cname = "WAKIT_IWEB_VIEW_GET_INTERFACE (self)->maximize")]
      extern const uintptr maximize_actv;

      [CCode (cname = "wakit_iweb_view_real_maximize")]
      extern const uintptr maximize_real;

      [CCode (cname = "wakit_iweb_view_signals[WAKIT_IWEB_VIEW_MAXIMIZE_SIGNAL]")]
      extern const uint maximize_sid;

      [HasEmitter, Signal (action = true, run = "first")]
      public virtual signal void maximize (bool @set, bool value)
        {

          if (! GLib.Signal.has_handler_pending (this, maximize_sid, 0, true)
             && maximize_actv == maximize_real)
            {

              GLib.warning_once ("Your application does not implement "
                               + "wakit_iweb_view_maximize() and has no handlers connected "
                               + "to the 'close' signal. It should do one of these.");
            }
        }

      [CCode (cname = "WAKIT_IWEB_VIEW_GET_INTERFACE (self)->minimize")]
      extern const uintptr minimize_actv;

      [CCode (cname = "wakit_iweb_view_real_minimize")]
      extern const uintptr minimize_real;

      [CCode (cname = "wakit_iweb_view_signals[WAKIT_IWEB_VIEW_MINIMIZE_SIGNAL]")]
      extern const uint minimize_sid;

      [HasEmitter, Signal (action = true, run = "first")]
      public virtual signal void minimize (bool @set, bool value)
        {

          if (! GLib.Signal.has_handler_pending (this, minimize_sid, 0, true)
             && minimize_actv == minimize_real)
            {

              GLib.warning_once ("Your application does not implement "
                               + "wakit_iweb_view_minimize() and has no handlers connected "
                               + "to the 'close' signal. It should do one of these.");
            }
        }

      [CCode (cname = "WAKIT_IWEB_VIEW_GET_INTERFACE (self)->terminated")]
      extern const uintptr terminated_actv;

      [CCode (cname = "wakit_iweb_view_real_terminated")]
      extern const uintptr terminated_real;

      [CCode (cname = "wakit_iweb_view_signals[WAKIT_IWEB_VIEW_TERMINATED_SIGNAL]")]
      extern const uint terminated_sid;

      [HasEmitter, Signal (run = "first")]
      public virtual signal void terminated (WebViewTerminationReason reason)
        {

          if (! GLib.Signal.has_handler_pending (this, terminated_sid, 0, true)
             && terminated_actv == terminated_real)
            {

              string str = Enum.to_string (reason, typeof (WebViewTerminationReason));
              critical ("WebView web process was terminated (reason = %s)", str);
            }
        }
    }
}