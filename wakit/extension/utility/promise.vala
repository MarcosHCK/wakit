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

  [CCode (ref_function = "wakit_promise_ref",
          unref_function = "wakit_promise_unref"),
   Compact (opaque = true)]
  public class Promise
    {

      private JSC.Context _context;
      private GLib.MainContext _main_context;
      private JSC.Value _reject;
      private JSC.Value _resolve;
      private uint _refs = 1;

      public JSC.Context context { get { return _context; } }

      internal Promise (JSC.Context context, JSC.Value reject, JSC.Value resolve)
        {

          _context = context;
          _main_context = GLib.MainContext.ref_thread_default ();
          _reject = reject;
          _resolve = resolve;
        }

      [CCode (scope = "async")]
      public delegate void Callback (Promise promise);

      public extern static JSC.Value create (JSC.Context context, owned Callback callback);

      public extern void free ();

      public unowned Promise @ref ()
        {

          GLib.AtomicUint.inc (ref _refs);
        return this;
        }

      public extern void reject (JSC.Value? value = null);
      public extern void reject_gerror (owned GLib.Error error);
      public extern void reject_literal (string value);
      [PrintfFormat]
      public extern void reject_printf (string fmt, ...);
      public extern void resolve (JSC.Value? value = null);

      [CCode (cheader_filename = "jsc/jsc.h", cname = "JSCExecutor",
              scope = "async")]
      public extern delegate void SimpleCallback (JSC.Value resolve, JSC.Value reject);

      [CCode (cheader_filename = "jsc/jsc.h", cname = "jsc_value_new_promise")]
      public extern static JSC.Value simple (JSC.Context context, owned SimpleCallback callback);

      public void @unref ()
        {

          if (GLib.AtomicUint.dec_and_test (ref _refs))
            free ();
        }
    }
}