{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    swaybg-config = {
      enable = lib.mkEnableOption "enables swaybg wallpaper configuration";

      selectedWallpaperPath = lib.mkOption {
        type = lib.types.str;
        internal = true;
        description = "The selected wallpaper path (for internal use)";
      };

      wallpaper = {
        path = lib.mkOption {
          type = lib.types.str;
          default = "~/Pictures/wallpapers";
          description = "Directory where wallpapers are stored";
        };

        preset = lib.mkOption {
          type = lib.types.enum ["nineish-dark-gray" "dracula" "mosaic-blue" "simple-dark-gray" "stripes-logo" "custom"];
          default = "dracula";
          description = "NixOS wallpaper preset to use, or 'custom' to use wallpaper.file";
        };

        file = lib.mkOption {
          type = lib.types.str;
          default = "default.jpg";
          description = "Wallpaper filename to use when preset is 'custom'";
        };
      };
    };
  };

  config = let
    wallpaperDir = config.swaybg-config.wallpaper.path;

    wallpapers = {
      nineish-dark-gray = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/master/wallpapers/nix-wallpaper-nineish-dark-gray.png";
        sha256 = "sha256-nhIUtCy/Hb8UbuxXeL3l3FMausjQrnjTVi1B3GkL9B8=";
      };
      dracula = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/master/wallpapers/nix-wallpaper-dracula.png";
        sha256 = "sha256-SykeFJXCzkeaxw06np0QkJCK28e0k30PdY8ZDVcQnh4=";
      };
      mosaic-blue = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/master/wallpapers/nix-wallpaper-mosaic-blue.png";
        sha256 = "sha256-xZbNK8s3/ooRvyeHGxhcYnnifeGAiAnUjw9EjJTWbLE=";
      };
      simple-dark-gray = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/master/wallpapers/nix-wallpaper-simple-dark-gray.png";
        sha256 = "sha256-JaLHdBxwrphKVherDVe5fgh+3zqUtpcwuNbjwrBlAok=";
      };
      stripes-logo = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/master/wallpapers/nix-wallpaper-stripes-logo.png";
        sha256 = "sha256-1MoPwytw8kBiy+Sx70xmHnxMJgqEaOR9YEgQMO6bEjM=";
      };
    };

    selectedWallpaper =
      if config.swaybg-config.wallpaper.preset == "custom"
      then "${wallpaperDir}/${config.swaybg-config.wallpaper.file}"
      else wallpapers.${config.swaybg-config.wallpaper.preset};
  in
    lib.mkIf config.swaybg-config.enable {
      swaybg-config.selectedWallpaperPath = "${selectedWallpaper}";

      home.packages = with pkgs; [swaybg];

      home.activation.createWallpaperDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p ${wallpaperDir}
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (
            name: path: "cp -f ${path} ${wallpaperDir}/nix-${name}.png"
          )
          wallpapers)}
      '';

      home.file.".config/swaybg/wallpaper-path".text = "${selectedWallpaper}";
    };
}
