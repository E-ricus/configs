# Boot configuration aspects — systemd-boot and lanzaboote (Secure Boot).
# Hosts include either den.aspects.boot-systemd or den.aspects.boot-lanzaboote.
{
  den,
  inputs,
  ...
}: let
  lanzabooteModule = inputs.lanzaboote.nixosModules.lanzaboote;
in {
  den.aspects.boot-systemd = {
    nixos = {...}: {
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.systemd-boot.enable = true;
    };
  };

  den.aspects.boot-lanzaboote = {
    nixos = {pkgs, ...}: {
      imports = [lanzabooteModule];

      boot.loader.efi.canTouchEfiVariables = true;
      # Disable systemd-boot when using lanzaboote
      boot.loader.systemd-boot.enable = false;

      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
        autoGenerateKeys.enable = true;
        autoEnrollKeys = {
          enable = true;
          autoReboot = true;
        };
      };

      environment.systemPackages = [pkgs.sbctl];
    };
  };
}
