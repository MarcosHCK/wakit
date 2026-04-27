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

namespace Wakit.Binding
{

  /**
   * Keep *_NAME_* constants in sync with host/browser/widget.vala
   * - note: at the start of the class definition
   */

  public sealed class BrowserWindow: GLib.Object, IBinding<BrowserWindow>, IInvocable<BrowserWindow>, ISignalable<BrowserWindow>
    {

      public Hub signal_hub { get; protected set; default = new Hub (); }
      public WebKit.WebPage? web_page { owned get { return (WebKit.WebPage) _web_page.get (); }
                                        construct { _web_page.set (value); } }

      private GLib.WeakRef _web_page;

      const string METHOD_NAME_CLOSE = "Wakit.BrowserWindow.Close";
      const string METHOD_NAME_MAXIMIZE = "Wakit.BrowserWindow.Maximize";
      const string METHOD_NAME_MINIMIZE = "Wakit.BrowserWindow.Minimize";

      const string SIGNAL_NAME_CLOSE = "Wakit.BrowserWindow.Close";
      const string SIGNAL_NAME_MAXIMIZED = "Wakit.BrowserWindow.Maximized";
      const string SIGNAL_NAME_MINIMIZED = "Wakit.BrowserWindow.Minimized";

      public BrowserWindow (WebKit.WebPage web_page)
        {

          Object (web_page: web_page);
        }

      public override void constructed ()
        {

          base.constructed ();
          web_page.user_message_received.connect (on_user_message_received);
        }

      private JSC.Value? invoke (GenericArray<JSC.Value> a, string name, string signature)
        {

          unowned JSC.Context context = JSC.Context.get_current ();
          unowned GLib.VariantType type = (GLib.VariantType) signature;
          WebKit.UserMessage? message = null;
          WebKit.WebPage? web_page = null;

          if (null == (web_page = this.web_page))
            {

              context.throw ("headless BrowserWindow");
              return null;
            }
          else try
            {

              var arguments = new JSC.Value.array_from_garray (context, a);
              var parameters = Marshalling.jsc_value_to_variant (context, type, arguments);

              message = new WebKit.UserMessage (name, parameters);
            }
          catch (GLib.Error error)
            {

              Error.throw (context, (owned) error);
              return null;
            }

          return Promise.create (context,

            p => web_page.send_message_to_view.begin (message, null, (o, res) =>
              invoke_complete (o, res, p)));
        }

      static void invoke_complete (GLib.Object? o, GLib.AsyncResult res, Wakit.Promise p)
        {

          try
            { var message = ((WebKit.WebPage) o).send_message_to_view.end (res);
              var variant = IpcResult.unpack (message.get_parameters ());
              p.resolve (Marshalling.variant_to_jsc_value (p.context, variant)); }
          catch (GLib.Error error)
            { p.reject_gerror ((owned) error); }
        }

      private bool on_user_message_received (WebKit.UserMessage message)
        {

          try
            {

              unowned var name = message.get_name ();
              GLib.Variant parameters = message.get_parameters ();

              return on_user_message_received_inner (name, parameters);
            }
          catch (GLib.Error error)
            {

              unowned uint code = error.code;
              unowned string domain = error.domain.to_string ();
              unowned string message_ = error.message.to_string ();

              warning ("couldn't process browser signal: %s: %u: %s", domain, code, message_);
            }
        return false;
        }

      static void on_user_message_received_check (GLib.Variant parameters, string format_string) throws GLib.Error
        {

          if (! parameters.check_format_string (format_string, false))
            throw new GLib.IOError.INVALID_ARGUMENT ("invalid command parameters");
        }

      private bool on_user_message_received_inner (string name, GLib.Variant parameters) throws GLib.Error
        {

          switch (name)
            {

            case SIGNAL_NAME_CLOSE: on_user_message_received_check (parameters, "()");
              _signal_hub.emit_vr (name, parameters);
              return true;

            case SIGNAL_NAME_MAXIMIZED: on_user_message_received_check (parameters, "(b)");
              _signal_hub.emit_vr (name, parameters);
              return true;

            case SIGNAL_NAME_MINIMIZED: on_user_message_received_check (parameters, "(b)");
              _signal_hub.emit_vr (name, parameters);
              return true;
            }
        return false;
        }

      public static unowned Class register (JSC.Context context, string? name = null)
        {

          unowned Class klass = IBinding<BrowserWindow>.register (context, name);

          IInvocable<BrowserWindow>.add_method (klass, "close",
            (c, a) => c.invoke (a, METHOD_NAME_CLOSE, "()"));
          IInvocable<BrowserWindow>.add_method (klass, "maximize",
            (c, a) => c.invoke (a, METHOD_NAME_MAXIMIZE, "(mb)"));
          IInvocable<BrowserWindow>.add_method (klass, "minimize",
            (c, a) => c.invoke (a, METHOD_NAME_MINIMIZE, "(mb)"));

          ISignalable<BrowserWindow>.prepare (klass, context);
          ISignalable<BrowserWindow>.add_signal (klass, "onClose", SIGNAL_NAME_CLOSE);
          ISignalable<BrowserWindow>.add_signal (klass, "onMaximized", SIGNAL_NAME_MAXIMIZED);
          ISignalable<BrowserWindow>.add_signal (klass, "onMinimized", SIGNAL_NAME_MINIMIZED);
        return klass;
        }
    }
}