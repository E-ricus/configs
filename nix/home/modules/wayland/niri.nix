{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [./wayland.nix];

  options = {
    niri-config = {
      enable = lib.mkEnableOption "enables niri window manager configuration";
    };
  };

  config = lib.mkIf config.niri-config.enable {
    xdg.configFile."niri/config.kdl".source = ../../config/wayland/niri.kdl;
    home.packages = with pkgs; [
      swaybg # wallpaper
    ];
    programs.fuzzel.enable = true; # Super+D in the default setting (app launcher)
    programs.swaylock.enable = true; # Super+Alt+L in the default setting (screen locker)
    services.swayidle.enable = true; # idle management daemon
  };
}
