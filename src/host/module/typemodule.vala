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

  public sealed class TypeModule: GLib.TypeModule, GLib.Initable, IModule
    {

      public const string MODULE_INIT_FUNC_NAME = "wakit_host_module_init";

      [CCode (has_target = false, scope = "forever")]
      delegate bool ModuleInitFunc (Host host, TypeModule type_module);

      public unowned Host host { get; construct; }
      public string filename { get; construct; }

      private GLib.Module? _module = null;
      private ModuleInitFunc? _module_init = null;

      public TypeModule (string filename, Host host) throws GLib.Error
        {

          Object (filename: filename, host: host);
          init (null);
        }

      public bool init (GLib.Cancellable? cancellable) throws GLib.Error
        {

          unowned GLib.ModuleFlags flag1 = 0;
          unowned GLib.ModuleFlags flags = flag1;

          _module = new GLib.Module (_filename, flags);

          void* symbol = null;

          if (_module.symbol (MODULE_INIT_FUNC_NAME, out symbol))

            _module_init = (ModuleInitFunc) symbol;
          else
            throw new GLib.ModuleError.FAILED ("can not find module init function");

        return use ();
        }

      public override bool load () requires (null != _module)
        {

        return _module_init (host, this);
        }

      public override void unload () requires (null != _module)
        {

          _module_init = null;
          _module = null;
        }
    }
}