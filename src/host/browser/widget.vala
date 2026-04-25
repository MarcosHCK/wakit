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

  /**
   * Keep *_NAME_* constants in sync with extension/bindings/browserwindow.vala
   * - note: at the start of the class definition
   */

  public class Widget: Gtk.Grid, IWebView
    {

      public bool maximized { get; set; }
      public WebKit.WebView web_view { get; construct; }

      private WidgetBinding? _binding = null;

      const string METHOD_NAME_CLOSE = "Wakit.BrowserWindow.Close";
      const string METHOD_NAME_DRAG = "Wakit.BrowserWindow.Drag";
      const string METHOD_NAME_MAXIMIZE = "Wakit.BrowserWindow.Maximize";
      const string METHOD_NAME_MINIMIZE = "Wakit.BrowserWindow.Minimize";

      const string SIGNAL_NAME_CLOSE = "Wakit.BrowserWindow.Close";
      const string SIGNAL_NAME_MAXIMIZED = "Wakit.BrowserWindow.Maximized";
      const string SIGNAL_NAME_MINIMIZED = "Wakit.BrowserWindow.Minimized";

      ~Widget ()
        {

          if (null != _binding)
            _binding.toplevel?.weak_unref (unbind_toplevel);
        }

      public Widget (WebKit.WebView web_view)
        {
          Object (web_view: web_view);
        }

      public void bind_toplevel (Gtk.Window? toplevel)
        {

          _binding = null; if (null == toplevel)
            return;

          _binding = new WidgetBinding (this, toplevel);
          toplevel.weak_ref (unbind_toplevel);
        }

      public override void constructed ()
        {

          base.constructed ();

          _web_view.hexpand = true;
          _web_view.vexpand = true;

          _web_view.decide_policy.connect (on_decide_policy);
          _web_view.permission_request.connect (on_permission_request);
          _web_view.user_message_received.connect (on_user_message_received);
          _web_view.web_process_terminated.connect (on_web_process_terminated);

          notify ["maximized"].connect (on_notify_maximized);

          attach (_web_view, 0, 0);
        }

      [CCode (cname = "WAKIT_BROWSER_WIDGET_GET_CLASS (self)->close")]
      extern const uintptr close_actv;

      [CCode (cname = "wakit_browser_widget_real_close")]
      extern const uintptr close_real;

      [CCode (cname = "wakit_browser_widget_signals[WAKIT_BROWSER_WIDGET_CLOSE_SIGNAL]")]
      extern const uint close_sid;

      [HasEmitter, Signal (action = true, run = "last")]
      public virtual signal void close ()
        {

          if (! GLib.Signal.has_handler_pending (this, close_sid, 0, true)
             && close_actv == close_real)
            {

              GLib.warning_once ("Your application does not implement "
                               + "wakit_browser_widget_close() and has no handlers connected "
                               + "to the 'close' signal. It should do one of these.");
            }
        }

      public void open_uri (GLib.File file, string hint)
        {

          _web_view.load_uri (file.get_uri ());
        }

      private bool on_decide_policy (WebKit.WebView webview, WebKit.PolicyDecision decision_base, WebKit.PolicyDecisionType type)
        {

          switch (type)
        {

          case WebKit.PolicyDecisionType.NAVIGATION_ACTION:
            { unowned WebKit.NavigationPolicyDecision decision = decision_base as WebKit.NavigationPolicyDecision;
              return on_decide_policy_navigation_action (webview, decision); }

          case WebKit.PolicyDecisionType.NEW_WINDOW_ACTION:
            { unowned WebKit.NavigationPolicyDecision decision = decision_base as WebKit.NavigationPolicyDecision;
              return on_decide_policy_new_window_action (webview, decision); }

          default: return false;
        } }

      static void on_decide_policy_ask (Gui.Message message, Gtk.Window parent, WebKit.PolicyDecision decision)
        {

          message.choose.begin (parent, null, (o, result) =>
            on_decide_policy_complete (o, result, decision));
        }

      static void on_decide_policy_complete (GLib.Object? o, GLib.AsyncResult result, WebKit.PolicyDecision decision)
        {

          try
            { 

              if (Gui.MessageResponse.YES == ((Gui.Message) o).choose.end (result))

                decision.use ();
              else
                decision.ignore ();
            }
          catch (GLib.Error error)
            {

              unowned uint code = error.code;
              unowned string domain = error.domain.to_string ();
              unowned string message = error.message.to_string ();

              warning ("can not retrieve policy choice: %s: %u: %s", domain, code, message);
              decision.ignore ();
            }
        }

      private bool on_decide_policy_navigation_action (WebKit.WebView webview, WebKit.NavigationPolicyDecision decision)
        {

          unowned var action = decision.navigation_action;

          if (! action.is_redirect ())
            {
              decision.use ();
              return true;
            }

          WebKit.URIRequest? request;

          if (null == (request = action.get_request ()))
            {
              decision.ignore ();
              return true;
            }

          var message = new Gui.Message.question ("%s wants to redirect to %s", webview.get_uri (),
                                                                                request.get_uri ());

          on_decide_policy_ask (message, _binding?.toplevel, decision);
        return true;
        }

      private bool on_decide_policy_new_window_action (WebKit.WebView webview, WebKit.NavigationPolicyDecision decision)
        {

          decision.ignore ();
          warning ("pop-up window blocked");
        return true;
        }

      private void on_notify_maximized () requires (null != _web_view)
        {

          var parameters = new GLib.Variant ("(b)", maximized);
          var message = new WebKit.UserMessage (SIGNAL_NAME_MAXIMIZED, parameters);

          _web_view.send_message_to_page.begin (message, null);
        }

      private bool on_permission_request (WebKit.WebView webview, WebKit.PermissionRequest request)
        {

          request.deny ();
          warning ("permission request (type %s) denied", request.get_type ().name ());
        return true;
        }

      private bool on_user_message_received (WebKit.UserMessage message)
        {

          unowned var name = message.get_name ();
          GLib.Variant result;

          try
            { GLib.Variant parameters = message.get_parameters ();
              GLib.Variant? value = on_user_message_received_inner (name, parameters);
              if (null == value) return false;
              result = IpcResult.pack_value (value); }
          catch (GLib.Error error)
            { result = IpcResult.pack_error (error); }

          message.send_reply (new WebKit.UserMessage (name, result));
        return true;
        }

      static void on_user_message_received_check (GLib.Variant parameters, string format_string) throws GLib.Error
        {

          if (! parameters.check_format_string (format_string, false))
            throw new GLib.IOError.INVALID_ARGUMENT ("invalid command parameters");
        }

      private GLib.Variant? on_user_message_received_inner (string name, GLib.Variant parameters) throws GLib.Error
        {

          switch (name)
            {

            case METHOD_NAME_CLOSE: close ();
              return new GLib.Variant.boolean (true);;

            case METHOD_NAME_DRAG: on_user_message_received_check (parameters, "(b)");
              { bool drag = parameters.get_child_value (0).get_boolean ();
                print ("drag = %s\n", drag ? "true" : "false");
                return new GLib.Variant.boolean (true);; }
            }
        return null;
        }

      private void on_web_process_terminated (WebKit.WebView webview, WebKit.WebProcessTerminationReason reason)
        {

          Wakit.WebViewTerminationReason _reason; switch (reason)
            {
            case WebKit.WebProcessTerminationReason.CRASHED: _reason = Wakit.WebViewTerminationReason.CRASH; break;
            case WebKit.WebProcessTerminationReason.EXCEEDED_MEMORY_LIMIT: _reason = Wakit.WebViewTerminationReason.OUT_OF_MEMORY; break;
            case WebKit.WebProcessTerminationReason.TERMINATED_BY_API: _reason = Wakit.WebViewTerminationReason.API_CALL; break;
            default: assert_not_reached ();
            }

          terminated (_reason);
        }

      private void unbind_toplevel ()
        {
        }
    }
}