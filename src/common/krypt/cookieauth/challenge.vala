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

  [Compact (opaque = true), CCode (ref_function = "wakit_krypt_cookie_auth_challenge_ref",
                                   unref_function = "wakit_krypt_cookie_auth_challenge_unref")]
  public class Challenge
    {

      uint _refs = 1;

      private uint8 _bytes [CHALLENGE_LENGTH];
      private uint64 _counter = 0;

      public Challenge ()
        {
        }

      public Challenge.random (uint64 counter)
        {

          _counter = counter;
          randomize (_bytes, RandomnessLevel.WEAK);
        }

      public extern void free () requires (null == @ref)
                                 requires (null == @unref);

      public async bool read (GLib.InputStream stream, int io_priority = GLib.Priority.DEFAULT, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          size_t bytes;
          uint8[] counter = (uint8[]) &_counter;

          counter.length = (int) sizeof (uint64);
          yield stream.read_all_async (_bytes, io_priority, cancellable, out bytes);
          yield stream.read_all_async (counter, io_priority, cancellable, out bytes);
        return true;
        }

      public unowned Challenge @ref ()
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
          uint8[] counter = (uint8[]) &_counter;

          counter.length = (int) sizeof (uint64);
          yield stream.write_all_async (_bytes, io_priority, cancellable, out bytes);
          yield stream.write_all_async (counter, io_priority, cancellable, out bytes);
        return true;
        }
    }
}