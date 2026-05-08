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

  public class BrowserConfig: GLib.Object
    {

      public override void constructed ()
        {

          base.constructed ();
          _preferred_language = _preferred_language ?? "en_US";
          _webrtc_udp_ports_range = _webrtc_udp_ports_range ?? "";
        }

      public string? application_id { get; construct set; default = null; }
      public string? application_version { get; construct set; default = null; }
      public uint appbus_launch_timeout { get; construct set; default = 2000; }
      public uint appbus_shutdown_timeout { get; construct set; default = 1000; }
      public bool auto_load_images { get; construct set; default = true; }
      public bool enable_dns_prefetching { get; construct set; default = false; }
      public bool enable_fullscreen { get; construct set; default = false; }
      public bool enable_html5_database { get; construct set; default = true; }
      public bool enable_html5_local_storage { get; construct set; default = true; }
      public bool enable_media { get; construct set; default = false; }
      public bool enable_mediasource { get; construct set; default = false; }
      public bool enable_media_stream { get; construct set; default = false; }
      public bool enable_media_capabilities { get; construct set; default = false; }
      public bool enable_resizable_text_areas { get; construct set; default = true; }
      public bool enable_smooth_scrolling { get; construct set; default = true; }
      public bool enable_spell_checking { get; construct set; default = false; }
      public bool enable_webaudio { get; construct set; default = false; }
      public bool enable_webgl { get; construct set; default = false; }
      public bool enable_webrtc { get; construct set; default = false; }
      public string preferred_language { get; construct set; default = "en_US"; }
      public string webrtc_udp_ports_range { get; construct set; default = ""; }
    }
}