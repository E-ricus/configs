# Boot configuration aspects — systemd-boot and lanzaboote (Secure Boot).
# Hosts import either nixos.boot-systemd or nixos.boot-lanzaboote.
{inputs, ...}: let
  lanzabooteModule = inputs.lanzaboote.nixosModules.lanzaboote;
in {
  flake.modules.nixos.boot-systemd = {...}: {
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot.enable = true;
  };

  flake.modules.nixos.boot-lanzaboote = {pkgs, ...}: {
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
}
