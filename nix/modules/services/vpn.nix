# VPN aspects — WireGuard tools + Mullvad VPN.
{...}: {
  den.aspects.vpn = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.wireguard-tools];
    };

    # Sub-aspect for Mullvad
    provides.mullvad = {
      nixos = {pkgs, ...}: {
        services.mullvad-vpn = {
          enable = true;
          package = pkgs.mullvad-vpn;
        };
        # These leaks dns but without it and the fallbadk, with the vpn off there is no connection
        # If commited to mullad, is possible to remove it.
        networking.nameservers = [
          "1.1.1.1"
          "1.0.0.1"
        ];
        services.resolved = {
          enable = true;
          settings = {
            Resolve = {
              DNSSEC = "true";
              Domains = ["~."];
              DNSOverTLS = "true";
              fallbackDns = [
                "1.1.1.1"
                "1.0.0.1"
              ];
            };
          };
        };
      };
    };
  };
}
