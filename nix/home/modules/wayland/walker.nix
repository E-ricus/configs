{
  config,
  pkgs,
  lib,
  walker,
  ...
}: {
  imports = [walker.homeManagerModules.default];

  options = {
    walker-config.enable =
      lib.mkEnableOption "enables walker launcher configuration";
  };

  config = lib.mkIf config.walker-config.enable {
    programs.walker = {
      enable = true;
      runAsService = true;
      # All options from the config.toml can be used here https://github.com/abenz1267/walker/blob/master/resources/config.toml
      config = {
        theme = "catppuccin";
        placeholders."default" = {
          input = "Search";
          list = "Example";
        };

        # Provider configuration: apps-only by default, others require prefixes
        providers = {
          # When query is empty, only show desktop applications
          empty = ["desktopapplications"];

          # By default (when typing), only show applications
          # Other providers require their prefix
          default = ["desktopapplications"];

          # Prefix mappings for all providers
          prefixes = [
            {
              provider = "websearch";
              prefix = "+";
            }
            {
              provider = "providerlist";
              prefix = "_";
            }
            {
              provider = "runner";
              prefix = ">";
            }
            {
              provider = "calc";
              prefix = "=";
            }
            {
              provider = "files";
              prefix = "/";
            }
            {
              provider = "symbols";
              prefix = ".";
            }
            {
              provider = "clipboard";
              prefix = ":";
            }
          ];
        };

        keybinds = {
          # For power menu niceties
          quick_activate = ["F1" "F2" "F3" "F4" "F5" "F6"];
          next = ["Down" "ctrl n"];
          previous = ["Up" "ctrl p"];
        };
      };

      # default css theme as an example https://github.com/abenz1267/walker/blob/master/resources/themes/default/style.css
      # default layouts for examples https://github.com/abenz1267/walker/tree/master/resources/themes/default
      themes = {
        "catppuccin" = {
          # Catppuccin Mocha themed style
          style = builtins.readFile ../../config/walker/style.css;
          layouts = {
            "layout" = builtins.readFile ../../config/walker/layout.xml;
            #add more provider-specific layouts here if needed:
            # "item_calc" = builtins.readFile (../../config/walker/item_calc.xml);
            # "item_files" = builtins.readFile (../../config/walker/item_files.xml);
          };
        };
      };

      # Configure elephant through walker's elephant option
      # This integrates with the elephant service and triggers automatic restarts
      elephant = {
        provider.websearch.settings = {
          # Show each search engine as a separate item instead of as actions
          # This allows you to see all engines when typing your query
          engines_as_actions = false;

          entries = [
            {
              default = true;
              name = "DuckDuckGo";
              url = "https://duckduckgo.com/?q=%TERM%";
              prefix = "d";
            }
            {
              name = "GitHub";
              url = "https://github.com/search?q=%TERM%";
              prefix = "g";
            }
            {
              name = "Nix packages";
              url = "https://search.nixos.org/packages?channel=unstable&query=%TERM%";
              prefix = "n";
            }
            {
              name = "Crates";
              url = "https://crates.io/search?q=%TERM%";
              prefix = "c";
            }
          ];
        };
      };
    };

    # Restart elephant service after home-manager activation
    # This ensures walker picks up new desktop applications
    home.activation.restartElephant = config.lib.dag.entryAfter ["reloadSystemd"] ''
      $DRY_RUN_CMD ${pkgs.systemd}/bin/systemctl --user restart elephant.service
    '';
  };
}
