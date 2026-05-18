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

  public class Widget: Gtk.Grid, IWebView
    {

      public bool maximized { get; set; }
      public bool minimized { get; set; }
      public WebKit.WebView web_view { get; construct; }

      private DragController _drag_controller;

      public Widget (WebKit.WebView web_view)
        {
          Object (web_view: web_view);
        }

      public override void constructed ()
        {

          base.constructed ();

          _drag_controller = new DragController (_web_view);

          _web_view.hexpand = true;
          _web_view.vexpand = true;

          _web_view.decide_policy.connect (on_decide_policy);
          _web_view.permission_request.connect (on_permission_request);
          _web_view.web_process_terminated.connect (on_web_process_terminated);

          add_controller (_drag_controller.controller);
          attach (_web_view, 0, 0);
        }

      public Gtk.Window? get_toplevel ()
        {

          unowned Gtk.Native? native = get_native ();
          unowned Gtk.Window? window = ! (native is Gtk.Window) ? null : (Gtk.Window) native;
        return window;
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

          on_decide_policy_ask (message, get_toplevel (), decision);
        return true;
        }

      private bool on_decide_policy_new_window_action (WebKit.WebView webview, WebKit.NavigationPolicyDecision decision)
        {

          decision.ignore ();
          warning ("pop-up window blocked");
        return true;
        }

      private bool on_permission_request (WebKit.WebView webview, WebKit.PermissionRequest request)
        {

          request.deny ();
          warning ("permission request (type %s) denied", request.get_type ().name ());
        return true;
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
    }
}