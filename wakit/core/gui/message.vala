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

namespace Wakit.Gui
{

  public enum MessageResponse
    {

      DEFAULT = 0,
      NO = 0,
      YES = 1,
    }

  [GtkTemplate (ui = "/org/hck/wakit/core/gtk/message.ui")] public class Message: Gtk.Window
    {

      [GtkChild] private unowned Gtk.Grid? grid1 = null;
      [GtkChild] private unowned Gtk.Image? image1 = null;
      [GtkChild] private unowned Gtk.Label? label1 = null;

      [CCode (cheader_filename = "wakit/core/gui/message.h")]
      extern const GLib.Quark BUTTON_ID_QUARK;

      [PrintfFormat] public Message.error (string format, ...)
        {
          Object ();
          begin (format, va_list ());
          complete ("dialog-error-symbolic", { ("Ok") });
        }

      [PrintfFormat] public Message.message (string format, ...)
        {
          Object ();
          begin (format, va_list ());
          complete ("dialog-information-symbolic", { ("Ok") });
        }

      [PrintfFormat] public Message.question (string format, ...)
        {
          Object ();
          begin (format, va_list ());
          complete ("dialog-question-symbolic", { ("No"), ("Yes") });
        }

      [PrintfFormat] public Message.warning (string format, ...)
        {
          Object ();
          begin (format, va_list ());
          complete ("dialog-warning-symbolic", { ("Ok") });
        }

      static Gtk.Window? _active_or_any ()
        {

          Gtk.Application? application = null;

          if ((application = GLib.Application.get_default () as Gtk.Application) == null)

            return null;
          else
            return application.active_window ?? application.get_windows ().nth (0)?.data;
        }

      private void add_buttons (string[] labels)
        {

          for (int i = 0; i < labels.length; ++i)
        {
            var button = new Gtk.Button.with_label (labels [i]);

            button.clicked.connect (on_button_clicked);
            button.set_qdata<int> (BUTTON_ID_QUARK, i);
            grid1.attach (button, i, 0);
        } }

      [PrintfFormat]
      private void begin (string format, va_list l)
        {
          label1.use_markup = true;
          label1.label = @"<big>$(GLib.Markup.vprintf_escaped (format, l))</big>";
        }

      [CCode (cheader_filename = "glib-object.h", cname = "g_cancellable_connect")]
      extern static ulong _g_cancellable_connect (GLib.Cancellable cancellable, GLib.Callback handler,
                                                  void* data, GLib.DestroyNotify? notify = null);

      [CCode (cheader_filename = "glib-object.h", cname = "g_signal_connect_data")]
      extern static ulong _g_signal_connect_data (GLib.Object instance, string detailed_signal, GLib.Callback handler,
                                                  void* data, GLib.ClosureNotify? notify = null, GLib.ConnectFlags flags = 0);

      public extern async int choose (Gtk.Window? parent = null, GLib.Cancellable? cancellable = null) throws GLib.Error;

      [CCode (cname = "wakit_gui_message_choose")]
      public void choose_ (Gtk.Window? parent, GLib.Cancellable? cancellable, GLib.AsyncReadyCallback callback)
        {

          var task = new GLib.Task (this, cancellable, callback);

          task.set_check_cancellable (true);
          task.set_source_tag ((void*) choose_);
          task.set_static_name ("[Wakit.Gui.Message.choose]");

          _g_cancellable_connect (cancellable, (GLib.Callback) choose_cancel,
                                  (void*) task.ref (), GLib.Object.unref);

          _g_signal_connect_data (this, "responded", (GLib.Callback) choose_action, 
                                  (void*) task.ref (), (GLib.ClosureNotify) GLib.Object.unref);

          task.set_task_data ((void*) @ref (), GLib.Object.unref);
          show (parent);
        }

      static void choose_action (Message self, int value, GLib.Task task)
        {

          GLib.SignalHandler.disconnect_by_func (self, (void*) choose_action, task);
          task.return_int ((ssize_t) value);
        }

      static void choose_cancel (GLib.Cancellable cancellable, GLib.Task task)
        {

          GLib.SignalHandler.disconnect_by_func (cancellable, (void*) choose_cancel, task);
          ((Message) task.get_task_data ()).close ();
        }

      public int choose_finish (GLib.AsyncResult result) throws GLib.Error
        {

          return (int) ((GLib.Task) result).propagate_int ();
        }

      private void complete (string icon_name, string[] labels)
        {
          image1.icon_name = icon_name;
          add_buttons (labels);
        }

      private void on_button_clicked (Gtk.Button button)
        {
          responded (button.get_qdata<int> (BUTTON_ID_QUARK));
        }

      [Signal (run = "first")]
      public signal void responded (int id)
        {
          close ();
        }

      public new void show (Gtk.Window? parent = null)
        {

          if ((parent = parent ?? _active_or_any ()) != null)

            set_transient_for (parent);
          else
            {
              Gtk.Application application;

              if ((application = GLib.Application.get_default () as Gtk.Application?) != null)
                application.add_window (this);
            }

          base.present ();
        }
    }
}