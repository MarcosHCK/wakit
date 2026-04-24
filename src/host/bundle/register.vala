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

namespace Wakit.Bundle
{

  [Compact (opaque = true)] private class Registrar
    {

      public Bundle bundle { get; }
      public string scheme { get; }

      public Registrar (string scheme, Bundle bundle)
        {

          _bundle = bundle;
          _scheme = scheme;
        }

      public extern void free ();

      public void handle_uri_scheme_request (IUriRequest request)
        {

          try
            { handle_uri_scheme_request_ (request); }
          catch (GLib.Error error)
            { request.finish_error (error); }
        }

      private void handle_uri_scheme_request_ (IUriRequest request) throws GLib.Error
        {

          unowned GLib.UriFlags flag1 = GLib.UriFlags.NONE;
          unowned GLib.UriFlags flags = flag1;

          GLib.Uri base_uri = GLib.Uri.build (flags, scheme, null, null, 0, "/", null, null);
          GLib.Uri rqst_uri = GLib.Uri.parse_relative (base_uri, request.uri, flags);

          GLib.Bytes bytes = _bundle.lookup_data (rqst_uri.get_path ());

          string filename = path_filename (rqst_uri.get_path ());
          string content_type = GLib.ContentType.guess (filename, bytes.get_data (), null);

          GLib.InputStream stream = new GLib.MemoryInputStream.from_bytes (bytes);

          request.finish (stream, bytes.get_size (), content_type);
        }

      static string path_filename (string path)
        {

          string dirname = GLib.Path.get_dirname (path);
          string filename = ! path.has_prefix (dirname) ? path : path.substring (dirname.length, -1);
        return filename;
        }
    }

  public static void register_uri_scheme_in_bundle (string scheme, IBrowser browser, Bundle bundle)
      requires (null != (void*) Registrar.free)
      requires (null != (void*) Registrar.handle_uri_scheme_request)
    {

      var registrar = new Registrar (scheme, bundle);
      register_uri_scheme_with_registrar (scheme, browser, (owned) registrar);
    }

  [CCode (cheader_filename = "host/bundle/register.c")]
  private extern static void register_uri_scheme_with_registrar (string scheme, IBrowser browser, owned Registrar registrar);
}