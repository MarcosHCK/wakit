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

  [CCode (cheader_filename = "wakit/extension/utility/marshalling.h")] namespace Marshalling
    {

      [CCode (returns_floating_reference = true)]
      public extern static GLib.Variant jsc_value_to_variant (JSC.Context context, GLib.VariantType type, JSC.Value value) throws GLib.Error;
      public extern static JSC.Value variant_to_jsc_value (JSC.Context context, GLib.Variant variant);
    }
}