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

namespace Wakit.Simple
{

  [GtkTemplate (ui = "/org/hck/wakit/host_simple/gtk/window.ui")]
  public class ApplicationWindow: Gtk.ApplicationWindow
    {

      [GtkChild] unowned Gtk.Grid? _grid = null;
      public Configuration.Config configuration { get; construct; }

      public ApplicationWindow (Configuration.Config configuration, Gtk.Application? application = null)
        {
          Object (application: application, configuration: configuration, decorated: configuration.decorated);
        }

      public new void set_child (Gtk.Widget widget)
        {
          _grid.attach (widget, 0, 0, 1, 1);
        }
    }
}