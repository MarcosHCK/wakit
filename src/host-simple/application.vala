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

  public class Application: Wakit.Application
    {

      public Configuration.Config configuration { get { return (Configuration.Config) browser_config; } }

      class construct
        {
          class_extend ();
        }

      public override void activate ()
        {

          string route;

          if (null == (route = configuration.default_route))

            open_uri (GLib.File.new_for_uri (route), "default_route");
          else
            open_uri (GLib.File.new_for_uri ("about:blank"), "default_route:not");
        }

      [CCode (cheader_filename = "host-simple/application.h")]
      extern class void class_extend ();

      void configure_scheme (Configuration.Scheme scheme_config) throws GLib.Error
        {

          unowned string scheme = scheme_config.name;

          Loaders.register_uri_scheme (scheme, browser, prepare_loader (scheme_config));

          if (scheme_config.local)
            browser.register_uri_scheme_as_local (scheme);

          if (scheme_config.secure)
            browser.register_uri_scheme_as_secure (scheme);
        }

      public override int handle_local_options (GLib.VariantDict options)
        {

          foreach (unowned var scheme_config in configuration.schemes) try
            {
              configure_scheme (scheme_config);
            }
          catch (GLib.OptionError error)
            {
              printerr ("%s", error.message);
              return 1;
            }
          catch (GLib.Error error)
            {
              unowned uint code = error.code;
              unowned string domain = error.domain.to_string ();
              unowned string message = error.message.to_string ();

              printerr ("Wakit.Simple.Application.configure_scheme ()!: %s: %u: %s\n", domain, code, message);
              return 1;
            }

        return base.handle_local_options (options);
        }

      Gtk.Window open_uri (GLib.File file, string hint)
        {

          IWebView web_view;

          var window = new ApplicationWindow (configuration, this);

          window.set_child (web_view = browser.create_view ());
          window.set_default_size (800, 600);

          web_view.bind_window (window);
          web_view.open_uri (file, hint);
        return window;
        }

      public override void open_uris ([CCode (array_length_cname = "n_files", array_length_pos = 1.5)] GLib.File[] files, string hint)
        {

          foreach (unowned var file in files)
              open_uri (file, hint).present ();
        }

      static Loaders.ILoader prepare_loader (Configuration.Scheme scheme_config) throws GLib.Error
        {

          Loaders.ILoader loader = null;
          unowned string? loader_bundle = scheme_config.bundle;
          unowned string? loader_tree = scheme_config.tree;

          if ((null == loader_bundle && null == loader_tree) || (null != loader_bundle && null != loader_tree))
            throw new GLib.OptionError.FAILED ("please specify one of --bundle or --tree");

          if (null != loader_bundle)
            loader = new Loaders.BundleLoader.from_file (loader_bundle);

          if (null != loader_tree)
            loader = new Loaders.TreeLoader (GLib.File.new_for_path (loader_tree));

          foreach (unowned var scheme_alias_config in scheme_config.aliases)
            {
              var alias = prepare_loader_alias (scheme_alias_config);
              loader.aliases.add (alias);
            }
        return loader;
        }

      static Loaders.Alias prepare_loader_alias (Configuration.SchemeAlias scheme_alias_config) throws GLib.Error
        {

          switch (GLib.Type.from_instance (scheme_alias_config).name ())
            {

          case "Wakit.Simple.Configuration.SchemaAbsoluteAlias":
            { unowned var config = (Configuration.SchemeAbsoluteAlias) scheme_alias_config;
              return new Loaders.AbsoluteAlias (config.path, config.replacement); }

          case "Wakit.Simple.Configuration.SchemaRegexAlias":
            { unowned var config = (Configuration.SchemeRegexAlias) scheme_alias_config;
              unowned var flags = GLib.RegexCompileFlags.OPTIMIZE;
              var regex = new GLib.Regex (config.pattern, flags, 0);
              return new Loaders.RegexAlias (regex, config.replacement); }

          case "Wakit.Simple.Configuration.SchemaVerbatimAlias":
            { return new Loaders.VerbatimAlias (); }

          default:
            GLib.error ("unknown object type '%s'", GLib.Type.from_instance (scheme_alias_config).name ());
        } }
    }
}