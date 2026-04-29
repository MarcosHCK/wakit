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

  [DBus (name = "org.hck.wakit.Browser.Window")]

  public interface IWindow: GLib.Object
    {

      [DBus (name = "close")]
      public abstract async void close () throws GLib.Error;

      [DBus (name = "closing")]
      public abstract signal void closing ();

      [DBus (name = "maximized")]
      public abstract bool maximized { owned get; set; }

      [DBus (name = "maximizedChanged")]
      public abstract signal void maximized_changed (bool value);

      [DBus (name = "maximizedToggle")]
      public abstract async void maximized_toggle () throws GLib.Error;

      [DBus (name = "minimized")]
      public abstract bool minimized { get; set; }

      [DBus (name = "minimizedChanged")]
      public abstract signal void minimized_changed (bool value);

      [DBus (name = "minimizedToggle")]
      public abstract async void minimized_toggle () throws GLib.Error;
    }
}