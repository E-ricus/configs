{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.graphics-config;
  intelCfg = cfg.intel;
in {
  options = {
    graphics-config = {
      enable = lib.mkEnableOption "enables graphics drivers";
      enable32Bit = lib.mkEnableOption "enables 32-bit graphics support (for gaming/Steam)";
      intel = {
        enable = lib.mkEnableOption "Intel GPU support (Xe/Arc) with VAAPI, QSV, and OpenCL";
        driver = lib.mkOption {
          type = lib.types.enum ["i915" "xe"];
          default = "i915";
          description = ''
            Intel GPU kernel driver to use.
            - "i915": stable default, supports all Intel GPUs.
            - "xe": newer driver for Gen12+ (Arc/Xe). Requires kernel >= 6.8.
              Experimental but may offer better performance and power management.
          '';
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # Base graphics config (always applied when graphics-config.enable = true)
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = cfg.enable32Bit;
      };
    }

    # Intel GPU config (Arc/Xe)
    # Configured based on nixos wiki: https://wiki.nixos.org/wiki/Intel_Graphics and NixOs hardware module: https://github.com/NixOS/nixos-hardware/blob/master/common/gpu/intel/default.nix
    (lib.mkIf intelCfg.enable {
      # Modesetting is the recommended driver for modern Intel GPUs
      services.xserver.videoDrivers = ["modesetting"];

      # Load the selected driver early in boot for display output during initrd
      boot.initrd.kernelModules = [intelCfg.driver];

      hardware.graphics.extraPackages = with pkgs; [
        intel-media-driver # VA-API (iHD) — hardware video encode/decode
        vpl-gpu-rt # oneVPL (QSV) — hardware video transcode (OBS, ffmpeg, etc.)
        intel-compute-runtime # OpenCL + Level Zero for Arc/Xe compute workloads
      ];

      # Diagnostic tools for verifying VAAPI is working (vainfo, etc.)
      environment.systemPackages = with pkgs; [
        libva-utils
      ];

      # Intel GPU firmware blobs
      hardware.enableRedistributableFirmware = true;

      # Enable GuC/HuC firmware loading — recommended for Arc/Xe GPUs.
      # Helps with VAAPI/QSV initialization and power management.
      # Only applies to i915; xe handles firmware loading automatically.
      boot.kernelParams = lib.optionals (intelCfg.driver == "i915") ["i915.enable_guc=3"];

      assertions = [
        {
          assertion = intelCfg.driver != "xe" || lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.8";
          message = "Intel Xe GPU driver requires kernel >= 6.8. Update your kernel or use the i915 driver.";
        }
      ];
    })
  ]);
}
