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

namespace Wakit.Host.Module
{

  public sealed class Host: GLib.Object, GLib.Initable
    {

      public string module_filename { construct; }
      public string module_loader { construct; }
      public ICollection<IPostable> postables { get; }

      private const string OBJECT_PATH = "/org/hck/wakit/host/module";
      private IModule? _module = null;

      public Host (string module_filename, string module_loader, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          Object (module_filename: module_filename, module_loader: module_loader);
          init (cancellable);
        }

      public override void constructed ()
        {

          base.constructed ();
          _postables = new AppBus.PostableCollection ();
        }

      public bool init (GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          unowned string filename = _module_filename;
          unowned string type = _module_loader;

          _module = IModule.create (filename, type, this, cancellable);
        return true;
        }

      public bool graft_on_connection (GLib.DBusConnection connection, GLib.Cancellable? cancellable = null) throws GLib.Error
          requires (null != _module)
        {

          ((AppBus.PostableCollection) _postables).post (connection, OBJECT_PATH);
        return true;
        }

      public void reap_on_connection (GLib.DBusConnection connection) throws GLib.Error
        {

          ((AppBus.PostableCollection) _postables).unpost (connection, OBJECT_PATH);
        }
    }
}