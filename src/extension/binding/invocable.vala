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

  public interface IInvocable<T>: GLib.Object, IBinding<T>
    {

      [CCode (scope = "notify")]
      public delegate JSC.Value? MethodCallback<T> (T instance, GenericArray<JSC.Value> args);

      public static void add_method (IBinding.Class klass, string name, owned MethodCallback<T> callback)
        {

          klass.jsc_class.add_method (name, (c, a) => callback ((T) c, a),
            typeof (JSC.Value));
        }
    }
}