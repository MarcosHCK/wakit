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

  public class Widget: Gtk.Grid, IWebView
    {

      public WebKit.WebView web_view { get; construct; }

      public Widget (WebKit.WebView web_view)
        {
          Object (web_view: web_view);
        }

      public override void constructed ()
        {

          base.constructed ();

          _web_view.hexpand = true;
          _web_view.vexpand = true;

          _web_view.web_process_terminated.connect (on_web_process_terminated);

          attach (_web_view, 0, 0);
        }

      public void open_uri (GLib.File file, string hint)
        {

          _web_view.load_uri (file.get_uri ());
        }

      private void on_web_process_terminated (WebKit.WebView webview, WebKit.WebProcessTerminationReason reason)
        {

          Wakit.WebViewTerminationReason _reason; switch (reason)
            {
            case WebKit.WebProcessTerminationReason.CRASHED: _reason = Wakit.WebViewTerminationReason.CRASH; break;
            case WebKit.WebProcessTerminationReason.EXCEEDED_MEMORY_LIMIT: _reason = Wakit.WebViewTerminationReason.OUT_OF_MEMORY; break;
            case WebKit.WebProcessTerminationReason.TERMINATED_BY_API: _reason = Wakit.WebViewTerminationReason.API_CALL; break;
            default: assert_not_reached ();
            }

          terminated (_reason);
        }
    }
}