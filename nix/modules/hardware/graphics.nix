# GPU driver aspects.
{config, ...}: let
  inherit (config.flake.modules) nixos;
in {
  # Basic graphics (no special GPU)
  flake.modules.nixos.graphics = {...}: {
    hardware.graphics.enable = true;
  };

  # Graphics with 32-bit support (for gaming/Steam)
  flake.modules.nixos.graphics-32bit = {...}: {
    imports = [nixos.graphics];
    hardware.graphics.enable32Bit = true;
  };

  # Intel GPU (Xe/Arc) with VAAPI, QSV, and OpenCL
  flake.modules.nixos.intel-graphics = {
    pkgs,
    lib,
    config,
    ...
  }: {
    imports = [nixos.graphics];
    services.xserver.videoDrivers = ["modesetting"];
    boot.initrd.kernelModules = ["xe"];

    hardware.graphics.extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
      intel-compute-runtime
    ];

    environment.systemPackages = [pkgs.libva-utils];
    hardware.enableRedistributableFirmware = true;

    assertions = [
      {
        assertion = lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.8";
        message = "Intel Xe GPU driver requires kernel >= 6.8.";
      }
    ];
  };
}
