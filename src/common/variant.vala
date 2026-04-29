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

namespace GLib
{

  [CCode (cheader_filename = "glib.h",
                     cname = "GVariantIter",
         has_copy_function = false,
      has_destroy_function = false,
               has_type_id = false,
        lower_case_csuffix = "variant_iter_")]

  public extern struct VariantIter_
    {

      public VariantIter_ (GLib.Variant variant)
        {
          this.constructor (variant);
        }

      [CCode (cheader_filename = "common/variant.c",
                         cname = "g_variant_iter_constructor")]
      private extern VariantIter_.constructor (GLib.Variant variant);

      [CCode (cname = "g_variant_iter_next")]
      public extern bool next (string format, ...);
    }
}