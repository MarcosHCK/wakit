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

namespace Wakit.Host
{

  public class Application: Wakit.Application, GLib.Initable
    {

      private Module.Registry _module_registry;

      [CCode (cname = "MODULE_HOST_BIN_PATH")]
      extern const string MODULE_HOST_BIN_PATH;

      class construct
        {
          class_extend ();
        }

      public Application (Configuration.Config configuration, GLib.Cancellable? cancellable = null) throws GLib.Error
        {

          Object (application_id: configuration.application_id,
                   configuration: configuration,
                           flags: GLib.ApplicationFlags.HANDLES_OPEN);

          if (null != configuration.application_version)
            set_version (configuration.application_version);

          init (cancellable);
        }

      public override void activate ()
        {

          string route;
          GLib.File files [1];

          if (null != (route = ((Configuration.Config) configuration).default_route))

            files [0] = GLib.File.new_for_uri (route);
          else
            files [0] = GLib.File.new_for_uri ("about:blank");

          open (files, "default-route");
        }

      [CCode (cheader_filename = "host/application.h")]
      extern class void class_extend ();

      void configure_module_registry ()
        {

          string str;

          if (unlikely (null != (str = GLib.Environment.get_variable ("WAKIT_MODULE_HOST_BIN"))))

            _module_registry.host_executable = str;
          else
            _module_registry.host_executable = MODULE_HOST_BIN_PATH;
        }

      void configure_scheme (Configuration.Scheme scheme_config) throws GLib.Error
        {

          unowned string scheme = scheme_config.name;

          Loaders.register_uri_scheme (scheme, browser, prepare_loader (scheme_config));

          if (scheme_config.cors_enabled)
            browser.register_uri_scheme_as_cors_enabled (scheme);

          if (scheme_config.local)
            browser.register_uri_scheme_as_local (scheme);
        }

      public override void constructed ()
        {

          base.constructed ();
          unowned var entries = Configuration.capture_entries ();

          add_main_option_entries (entries);
        }

      public bool init (GLib.Cancellable? cancellable) throws GLib.Error
        {

          unowned var config = (Configuration.Config) configuration;
  
          if (null != config.extensions_dir)
            extension_host.extension_dir = config.extensions_dir;

          foreach (unowned var scheme_config in config.schemes.data)
            configure_scheme (scheme_config);

          foreach (unowned var secure_scheme in config.secure_schemes.data)
            {
              browser.register_uri_scheme_as_secure (secure_scheme);
              extension_host.secure_schemes.add (secure_scheme);
            }

        return true;
        }

      Gtk.Window open_uri (GLib.File file, string hint)
        {

          IWebView web_view;

          var window = new ApplicationWindow ((Configuration.Config) configuration, this);

          window.set_child (web_view = browser.create_view ());
          window.set_default_size (800, 600);

          foreach (unowned var scheme in ((Wakit.Host.Configuration.Config) configuration).secure_schemes.data)
            {
              web_view.secure_schemes.add (scheme);
            }

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
            throw new GLib.OptionError.FAILED (_ ("please specify one of --bundle or --tree"));

          if (null != loader_bundle)
            loader = new Loaders.BundleLoader.from_file (loader_bundle);

          if (null != loader_tree)
            loader = new Loaders.TreeLoader (GLib.File.new_for_path (loader_tree));

          foreach (unowned var scheme_alias_config in scheme_config.aliases.data)
            {
              var alias = prepare_loader_alias (scheme_alias_config);
              loader.aliases.add (alias);
            }
        return loader;
        }

      static Loaders.Alias prepare_loader_alias (Configuration.SchemeAlias scheme_alias_config) throws GLib.Error
        {

          switch (scheme_alias_config.type)
            {

          case Wakit.Host.Configuration.SchemeAliasType.ABSOLUTE:
            { unowned var config = (Configuration.SchemeAbsoluteAlias) scheme_alias_config;
              return new Loaders.AbsoluteAlias (config.path, config.replacement); }

          case Wakit.Host.Configuration.SchemeAliasType.REGEX:
            { unowned var config = (Configuration.SchemeRegexAlias) scheme_alias_config;
              unowned var flags = GLib.RegexCompileFlags.OPTIMIZE;
              var regex = new GLib.Regex (config.pattern, flags, 0);
              return new Loaders.RegexAlias (regex, config.replacement); }

          case Wakit.Host.Configuration.SchemeAliasType.VERBATIM:
            { return new Loaders.VerbatimAlias (); }

          default:
            assert_not_reached ();
        } }

      public override async void shutdown_async ()
        {

          unowned var config = (Configuration.Config) configuration;

          yield base.shutdown_async ();
          yield _module_registry.quit_async (config.modules.shutdown_timeout);
        }

      public override async bool startup_async (GLib.Cancellable? cancellable) throws GLib.Error
        {

          Module.RegistryPostable postable;
          appbus.postables.add (postable = new Module.RegistryPostable ());

          yield base.startup_async ();

          _module_registry = (Module.Registry) GLib.Object.new (typeof (Module.Registry),
            "bus-address", appbus_address,
            "configuration", configuration,
            null);

          configure_module_registry ();

          yield (postable.registry = _module_registry).init_async (GLib.Priority.DEFAULT, cancellable);
        return true;
        }
    }
}