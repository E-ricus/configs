{
  config,
  pkgs,
  lib,
  ...
}: {
  # Convenient shell aliases that call the vpn script
  programs.fish.shellAliases = lib.mkIf config.programs.fish.enable {
    vpn-up = "vpn up";
    vpn-down = "vpn down";
    vpn-status = "vpn status";
    vpn-toggle = "vpn toggle";
  };

  programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
    vpn-up = "vpn up";
    vpn-down = "vpn down";
    vpn-status = "vpn status";
    vpn-toggle = "vpn toggle";
  };

  # Optional: Create helper scripts
  home.packages = [
    (pkgs.writeShellScriptBin "vpn" ''
      case "$1" in
        up|start|on)
          sudo wg-quick up ~/.config/wireguard/laptop.conf
          ;;
        down|stop|off)
          sudo wg-quick down ~/.config/wireguard/laptop.conf
          ;;
        status)
          sudo wg show
          ;;
        toggle)
          if sudo wg show wg0 &>/dev/null; then
            sudo wg-quick down ~/.config/wireguard/laptop.conf
          else
            sudo wg-quick up ~/.config/wireguard/laptop.conf
          fi
          ;;
        *)
          echo "Usage: vpn {up|down|status|toggle}"
          exit 1
          ;;
      esac
    '')
  ];
}
