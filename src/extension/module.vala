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

  [CCode (cname = "webkit_web_process_extension_initialize")]
  public static extern void webkit_web_process_extension_initialize (WebKit.WebProcessExtension extension);

  [CCode (cname = "webkit_web_process_extension_initialize_with_user_data")]
  public static extern void webkit_web_process_extension_initialize_with_user_data (WebKit.WebProcessExtension extension,
                                                                                    [CCode (type = "const GVariant*")]
                                                                                    GLib.Variant user_data);
}