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

namespace Wakit.Loaders
{

  class Registrar
    {

      public ILoader loader { get; private set; }
      public string scheme { get; private set; }

      public Registrar (string scheme, ILoader loader)
        {

          _loader = loader;
          _scheme = scheme;
        }

      public void handle_uri_scheme_request (IUriRequest request)
        {

          handle_uri_scheme_request_async.begin (request);
        }

      private async void handle_uri_scheme_request_async (IUriRequest request)
        {

          try
            { yield handle_uri_scheme_request_async_e (request); }
          catch (GLib.Error error)
            { request.finish_error (error); }
        }

      private async void handle_uri_scheme_request_async_e (IUriRequest request) throws GLib.Error
        {

          unowned GLib.UriFlags flag1 = GLib.UriFlags.NONE;
          unowned GLib.UriFlags flags = flag1;

          GLib.Uri base_uri = GLib.Uri.build (flags, scheme, null, null, 0, "/", null, null);
          GLib.Uri rqst_uri = GLib.Uri.parse_relative (base_uri, request.uri, flags);

          ILoader.Resource resource = yield _loader.load (rqst_uri.get_path ());

          request.finish (resource.stream, resource.info.size, resource.info.content_type);
        }
    }

  public static void register_uri_scheme (string scheme, IBrowser browser, ILoader loader)
    {

      var resolver = new Registrar (scheme, loader);
      browser.register_uri_scheme (scheme, resolver.handle_uri_scheme_request);
    }
}