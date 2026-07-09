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

  public class Browser: GLib.Object, IBrowser
    {

      public Configuration.Config config { construct; }
      public WebKit.WebContext context { get; private set; }
      public WebKit.Settings settings { get; private set; }
      public WebKit.UserContentManager user_content_manager { get; private set; }

      public Browser (Configuration.Config config)
        {

          Object (config: config);
        }

      public override void constructed ()
        {

          base.constructed ();

          _context = (WebKit.WebContext) GLib.Object.new (typeof (WebKit.WebContext),
            null);

          _context.set_automation_allowed (false);
          _context.set_cache_model (WebKit.CacheModel.DOCUMENT_BROWSER);
          _context.set_spell_checking_enabled (_config.enable_spell_checking);

          _settings = (WebKit.Settings) GLib.Object.new (typeof (WebKit.Settings),
            "allow-file-access-from-file-urls", false,
            "allow-modal-dialogs", false,
            "allow-top-navigation-to-data-urls", false,
            "allow-universal-access-from-file-urls", false,
            "default-charset", "UTF-8",
            "enable-back-forward-navigation-gestures", false,
            "enable-developer-extras", BuildConfig.DEVELOP,
            "enable-dns-prefetching", _config.enable_dns_prefetching,
            "enable-fullscreen", _config.enable_fullscreen,
            "enable-html5-database", _config.enable_html5_database,
            "enable-html5-local-storage", _config.enable_html5_local_storage,
            "enable-media-capabilities", _config.enable_media_capabilities,
            "enable-media-stream", _config.enable_media_stream,
            "enable-media", _config.enable_media,
            "enable-mediasource", _config.enable_mediasource,
            "enable-mock-capture-devices", false,
            "enable-page-cache", false,
            "enable-site-specific-quirks", false,
            "enable-webaudio", _config.enable_webaudio,
            "enable-webgl", _config.enable_webgl,
            "enable-webrtc", _config.enable_webrtc,
            "enable-write-console-messages-to-stdout", BuildConfig.DEBUG,
            "hardware-acceleration-policy", WebKit.HardwareAccelerationPolicy.NEVER,
            "javascript-can-access-clipboard", false,
            "javascript-can-open-windows-automatically", false,
            null);

          var application_name = make_application_name (_config.application_id);

          _settings.set_user_agent_with_application_details (application_name, _config.application_version);

          _user_content_manager = (WebKit.UserContentManager) GLib.Object.new (typeof (WebKit.UserContentManager),
            null);

          string allow_list [] = { "app:///*" };

          unowned var resource = Resource.peek ();

          GLib.Bytes css = lookup_build_resource (resource, "/org/hck/wakit/browser/browser.min.css");
          GLib.Bytes js = lookup_build_resource (resource, "/org/hck/wakit/browser/browser.min.js");

          _user_content_manager.add_script (new WebKit.UserScript ((string) js.get_data (),
                                                                   WebKit.UserContentInjectedFrames.ALL_FRAMES,
                                                                   WebKit.UserScriptInjectionTime.END,
                                                                   allow_list, null));

          _user_content_manager.add_style_sheet (new WebKit.UserStyleSheet ((string) css.get_data (),
                                                                            WebKit.UserContentInjectedFrames.ALL_FRAMES,
                                                                            WebKit.UserStyleLevel.USER,
                                                                            allow_list, null));
        }

      public Wakit.IWebView create_view ()
        {

          Wakit.Browser.Widget _widget;
          WebKit.WebView _web_view;

          _web_view = (WebKit.WebView) GLib.Object.new (typeof (WebKit.WebView),
            "settings", _settings,
            "user-content-manager", _user_content_manager,
            "web-context", _context,
            null);

          _widget = new Wakit.Browser.Widget (_web_view);

          created_view (_widget);
        return _widget;
        }

      [HasEmitter]
      public signal void created_view (Wakit.Browser.Widget web_view);

      static string make_application_name (string? application_id)
        {

          unowned string name = "Wakit";

          if (null == application_id)

            return name;
          else
            return @"$application_id $name";
        }

      public void register_uri_scheme (string scheme, owned UriRequestResolver resolver)
        {

          _context.register_uri_scheme (scheme, (_request) =>
            {
              var request = new UriRequest (_request);
              resolver (request);
            });
        }

      public void register_uri_scheme_as_local (string scheme)
        {

          _context.get_security_manager ().register_uri_scheme_as_local (scheme);
        }

      public void register_uri_scheme_as_secure (string scheme)
        {

          _context.get_security_manager ().register_uri_scheme_as_secure (scheme);
        }
    }
}
