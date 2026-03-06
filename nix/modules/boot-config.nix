{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.boot-config;
in {
  imports = [inputs.lanzaboote.nixosModules.lanzaboote];

  options.boot-config = {
    enable = lib.mkEnableOption "boot configuration";

    type = lib.mkOption {
      type = lib.types.enum ["systemd-boot" "lanzaboote"];
      default = "systemd-boot";
      description = "Bootloader type. 'lanzaboote' enables Secure Boot.";
    };

    pkiBundle = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/sbctl";
      description = "Path to the lanzaboote PKI bundle for secure boot.";
    };

    autoEnrollKeys = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Auto-generate and enroll Secure Boot keys on first boot (lanzaboote only).";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.loader.efi.canTouchEfiVariables = true;

    # systemd-boot (default)
    boot.loader.systemd-boot.enable = cfg.type == "systemd-boot";

    # lanzaboote (secure boot)
    boot.lanzaboote = lib.mkIf (cfg.type == "lanzaboote") {
      enable = true;
      pkiBundle = cfg.pkiBundle;
      autoGenerateKeys.enable = cfg.autoEnrollKeys;
      autoEnrollKeys = {
        enable = cfg.autoEnrollKeys;
        autoReboot = true;
      };
    };

    environment.systemPackages = lib.mkIf (cfg.type == "lanzaboote") [
      pkgs.sbctl
    ];
  };
}
