{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    graphics-config = {
      enable = lib.mkEnableOption "enables graphics drivers";
      enable32Bit = lib.mkEnableOption "enables 32-bit graphics support (for gaming/Steam)";
    };
  };

  config = lib.mkIf config.graphics-config.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = config.graphics-config.enable32Bit;
    };
  };
}
