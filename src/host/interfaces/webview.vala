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

      [CCode (cname = "WAKIT_IWEB_VIEW_GET_INTERFACE (self)->terminated")]
      extern const uintptr terminated_actv;

      [CCode (cname = "wakit_iweb_view_real_terminated")]
      extern const uintptr terminated_real;

      [CCode (cname = "wakit_iweb_view_signals[WAKIT_IWEB_VIEW_TERMINATED_SIGNAL]")]
      extern const uint terminated_sid;

      [HasEmitter]
      [Signal (run = "last")]
      public virtual signal void terminated (WebViewTerminationReason reason)
        {

          if (! GLib.Signal.has_handler_pending (this, terminated_sid, 0, true)
             && terminated_actv == terminated_real)
            {

              string str = Enum.to_string<WebViewTerminationReason> (reason);
              critical ("WebView web process was terminated (reason = %s)", str);
            }
        }
    }
}