{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    vpn.enable =
      lib.mkEnableOption "enables vpn configs";
    vpn.mullvad.enable = lib.mkEnableOption "enables mullvad vpn";
  };

  config = lib.mkMerge [
    (lib.mkIf config.vpn.enable {
      environment.systemPackages = with pkgs; [
        wireguard-tools
      ];
    })
    (lib.mkIf (config.vpn.enable && config.vpn.mullvad.enable) {
      services.mullvad-vpn = {
        enable = true;
        package = pkgs.mullvad-vpn;
      };
      # Needed due to: https://wiki.nixos.org/wiki/Mullvad_VPN
      services.resolved = {
        enable = true;
        settings = {
          Resolve = {
            DNSSEC = "true";
            Domains = ["~."];
            DNSOverTLS = "true";
            FallbackDNS = "";
          };
        };
      };
    })
  ];
}
