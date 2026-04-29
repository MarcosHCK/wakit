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

  public sealed class Window: GLib.Object, IWindow
    {

      private GLib.WeakRef _web_view;

      public IWebView? web_view { owned get { return (IWebView) _web_view.get (); }
                                  construct { _web_view.set (value); } }

      construct
        {

          /* use explicitly construct since Vala uses GObject::constructor to
           * implement this code block, and an strong reference to web_view
           * is guaranteed to be held.
           */
          var web_view = this.web_view;

          web_view.notify ["maximized"].connect (on_notify_maximized);
          web_view.notify ["minimized"].connect (on_notify_minimized);
        }

      public Window (IWebView web_view)
        {

          Object (web_view: web_view);
        }

      public async void close () throws GLib.Error
        {

          web_view?.close ();
        }

      public bool maximized { owned get { return web_view?.maximized ?? false; }
                              set { var web_view = this.web_view; if (null != web_view)
                                    web_view.maximized = value; } }

      public async void maximized_toggle () throws GLib.Error
        {

          maximized = !maximized;
        }

      public bool minimized { owned get { return web_view?.minimized ?? false; }
                              set { var web_view = this.web_view; if (null != web_view)
                                    web_view.minimized = value; } }

      public async void minimized_toggle () throws GLib.Error
        {

          minimized = !minimized;
        }

      private void on_notify_maximized (GLib.Object object, GLib.ParamSpec p_spec)
        {

          maximized_changed (((IWebView) object).maximized);
        }

      private void on_notify_minimized (GLib.Object object, GLib.ParamSpec p_spec)
        {

          minimized_changed (((IWebView) object).maximized);
        }
    }
}