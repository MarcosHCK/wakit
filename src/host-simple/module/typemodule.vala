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

namespace Wakit.Simple.Module
{

  public sealed class TypeModule: GLib.TypeModule, GLib.Initable
    {

      public const string MODULE_INIT_FUNC_NAME = "wakit_simple_module_init";

      [CCode (has_target = false)]
      delegate bool ModuleInitFunc (TypeModule module, Application application);

      public unowned Application application { get; construct; }
      public string filename { get; construct; }

      private GLib.Module? _module = null;
      private ModuleInitFunc? _module_init = null;

      public TypeModule (string filename, Application application) throws GLib.Error
        {

          Object (application: application, filename: filename);
          init (null);
        }

      public bool init (GLib.Cancellable? cancellable) throws GLib.Error
        {

          unowned GLib.ModuleFlags flag1 = GLib.ModuleFlags.LOCAL;
          unowned GLib.ModuleFlags flags = flag1;

          _module = new GLib.Module (_filename, flags);

          void* symbol = null;

          if (_module.symbol (MODULE_INIT_FUNC_NAME, out symbol))

            _module_init = (ModuleInitFunc) symbol;
          else
            throw new GLib.ModuleError.FAILED ("can not find module init function");

        return true;
        }

      public override bool load () requires (null != _module)
        {

        return _module_init (this, application);
        }

      public override void unload () requires (null != _module)
        {

          _module_init = null;
          _module = null;
        }
    }
}