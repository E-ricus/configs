# VPN aspects — WireGuard tools + Mullvad VPN.
{den, ...}: {
  den.aspects.vpn = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.wireguard-tools];
    };

    # Sub-aspect for Mullvad
    provides.mullvad = {
      nixos = {
        pkgs,
        lib,
        ...
      }: {
        services.mullvad-vpn = {
          enable = true;
          package = pkgs.mullvad-vpn;
        };
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
      };
    };
  };
}
