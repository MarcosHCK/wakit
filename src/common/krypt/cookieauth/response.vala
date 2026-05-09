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
using Wakit.Krypt.GCrypt;

namespace Wakit.Krypt.CookieAuth
{

  [Compact (opaque = true), CCode (ref_function = "wakit_krypt_cookie_auth_response_ref",
                                   unref_function = "wakit_krypt_cookie_auth_response_unref")]
  public class Response
    {

      uint _refs = 1;

      private uint8 _bytes [CHALLENGE_BYTE_LENGTH];
      private uint8 _iv [CIPHER_IV_BYTE_LENGTH];

      public uint8[] bytes { get { return _bytes; } }
      public uint8[] iv { get { return _iv; } }

      public Response ()
        {
        }

      public extern void free () requires (null == @ref)
                                 requires (null == @unref);

      public async bool read (GLib.InputStream stream, int io_priority = GLib.Priority.DEFAULT, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          size_t bytes;

          yield stream.read_all_async (_bytes, io_priority, cancellable, out bytes);
          yield stream.read_all_async (_iv, io_priority, cancellable, out bytes);
        return true;
        }

      public unowned Response @ref ()
        {

          AtomicUint.inc (ref _refs);
        return this;
        }

      public void @unref ()
        {

          if (AtomicUint.dec_and_test (ref _refs))
            free ();
        }

      public async bool write (GLib.OutputStream stream, int io_priority = GLib.Priority.DEFAULT, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          size_t bytes;

          yield stream.write_all_async (_bytes, io_priority, cancellable, out bytes);
          yield stream.write_all_async (_iv, io_priority, cancellable, out bytes);
        return true;
        }
    }
}