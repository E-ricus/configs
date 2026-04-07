# Alacritty terminal emulator — wrapped with baked-in config.
# Run standalone: nix run .#alacritty
{self, inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.alacritty = inputs.wrapper-modules.wrappers.alacritty.wrap {
      inherit pkgs;
      settings = {
        window = {
          option_as_alt = "Both";
          padding = {x = 10; y = 10;};
          opacity = 0.95;
        };
        font = {
          normal = {family = "JetBrainsMono Nerd Font"; style = "Regular";};
          italic = {family = "JetBrainsMono Nerd Font"; style = "Italic";};
          bold = {family = "JetBrainsMono Nerd Font"; style = "Bold";};
          size = 12.0;
        };
        colors.primary = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
        };
      };
    };
  };

  den.aspects.alacritty = {
    homeManager = {pkgs, ...}: {
      home.packages = [self.packages.${pkgs.stdenv.hostPlatform.system}.alacritty];
    };
  };
}
