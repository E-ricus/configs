# GPU driver aspects.
{den, ...}: {
  # Basic graphics (no special GPU)
  den.aspects.graphics = {
    nixos = {...}: {
      hardware.graphics.enable = true;
    };
  };

  # Graphics with 32-bit support (for gaming/Steam)
  den.aspects.graphics-32bit = {
    includes = [den.aspects.graphics];
    nixos = {...}: {
      hardware.graphics.enable32Bit = true;
    };
  };

  # Intel GPU (Xe/Arc) with VAAPI, QSV, and OpenCL
  den.aspects.intel-graphics = {
    includes = [den.aspects.graphics];
    nixos = {
      pkgs,
      lib,
      config,
      ...
    }: {
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
  };
}
