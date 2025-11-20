{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    minimal-packages.enable =
      lib.mkEnableOption "enables minimal system packages and fonts";
  };

  config = lib.mkIf config.minimal-packages.enable {
    # Essential system packages
    environment.systemPackages = with pkgs; [
      git
      wget
      curl
      vim
      home-manager
      fish
      wireguard-tools
      usbutils
    ];

    # Enable fish shell system-wide
    programs.fish.enable = true;

    # Fonts
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      font-awesome
      pkgs.nerd-fonts.jetbrains-mono
      pkgs.nerd-fonts.fira-code
      pkgs.nerd-fonts.hack
    ];
  };
}
