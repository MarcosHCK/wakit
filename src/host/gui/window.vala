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

  [GtkTemplate (ui = "/org/hck/wakit/gtk/window.ui")]

  public class Window: Gtk.ApplicationWindow
    {

      private bool _has_titlebar;
      public bool has_titlebar { get { return _has_titlebar; }
                        construct set { set_titlebar (_has_titlebar = value); } }

      public Window (Gtk.Application application)
        {
          Object (application: application);
        }

      private new void set_titlebar (bool value)
        {

          Gtk.Widget _bar = null; if (value)
            _bar = new Gui.HeaderBar ();

          base.set_titlebar (_bar);
        }
    }
}