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

  public class Maker: GLib.Object, IBrowser
    {

      public string? application_id { private get; construct; default = null; }
      public string application_version { private get; construct; default = Config.PACKAGE_VERSION; }
      public WebKit.WebContext context { get; private set; }
      public WebKit.Settings settings { get; private set; }
      public WebKit.UserContentManager user_content_manager { get; private set; }

      private string application_name { owned get
        {
          var name = "Wakit";
          var appid = (string?) null;

          if (null != (appid = application_id))
            name += @": $appid";
        return name;
        }}

      public override void constructed ()
        {

          _context = (WebKit.WebContext) GLib.Object.new (typeof (WebKit.WebContext),
            null);

          _settings = (WebKit.Settings) GLib.Object.new (typeof (WebKit.Settings),
            "allow-file-access-from-file-urls", false,
            "allow-modal-dialogs", false,
            "allow-top-navigation-to-data-urls", false,
            "allow-universal-access-from-file-urls", false,
            "default-charset", "UTF-8",
            "enable-back-forward-navigation-gestures", false,
            "enable-developer-extras", Config.DEVELOP,
            "enable-fullscreen", false,
            "enable-page-cache", false,
            "enable-site-specific-quirks", false,
            "enable-write-console-messages-to-stdout", Config.DEBUG,
            "javascript-can-open-windows-automatically", false,
            null);

          _settings.set_user_agent_with_application_details (application_name, application_version);

          _user_content_manager = (WebKit.UserContentManager) GLib.Object.new (typeof (WebKit.UserContentManager),
            null);

          // var _security = (WebKit.SecurityManager) _context.get_security_manager ();

          _context.set_cache_model (WebKit.CacheModel.DOCUMENT_BROWSER);
        }

      public Wakit.IWebView make_viewer ()
        {

          WebKit.WebView _viewer;

          _viewer = (WebKit.WebView) GLib.Object.new (typeof (WebKit.WebView),
            "settings", _settings,
            "user-content-manager", _user_content_manager,
            "web-context", _context,
            null);

        return new Browser.Widget (_viewer);
        }
    }
}