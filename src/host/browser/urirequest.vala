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

  internal sealed class UriRequest: GLib.Object, IUriRequest
    {

      public GLib.InputStream body { owned get { return _request.get_http_body (); } }
      public IUriRequestHeaders headers { owned get { return _get_headers (); } }
      public string method { get { return _request.get_http_method (); } }
      public string path { get { return _request.get_path (); } }
      public string scheme { get { return _request.get_scheme (); } }
      public string uri { get { return _request.get_uri (); } }

      private WebKit.URISchemeRequest _request;

      public UriRequest (WebKit.URISchemeRequest request)
        {

          _request = request;
        }

      public void finish (GLib.InputStream stream, int64 length = -1, string? content_type = null)
        {

          _request.finish (stream, length, content_type);
        }

      public void finish_error (GLib.Error error)
        {
          _request.finish_error (error);
        }

      private UriRequestHeaders _get_headers ()
        {

          var headers = _request.get_http_headers ();
          var result = new UriRequestHeaders (_request, headers);
        return result;
        }
    }

  internal sealed class UriRequestHeaders: GLib.Object, IUriRequestHeaders
    {

      unowned Soup.MessageHeaders _headers;
      WebKit.URISchemeRequest _request;

      internal UriRequestHeaders (WebKit.URISchemeRequest request, Soup.MessageHeaders headers)
        {

          _headers = headers;
          _request = request;
        }

      public void @foreach (ForeachHeader @foreach)
        {

          foreach_impl (_headers, @foreach);
        }

      [CCode (cheader_filename = "host/browser/urirequest.h")]
      extern static void foreach_impl (Soup.MessageHeaders headers, ForeachHeader @foreach);

      public string get_list (string header_name)
        {

          return _headers.get_list (header_name);
        }

      public string get_one (string header_name)
        {

          return _headers.get_one (header_name);
        }
    }
}