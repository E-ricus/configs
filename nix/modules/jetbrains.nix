{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    jetbrains.enable =
      lib.mkEnableOption "enables jetbrains tools";
  };

  config = lib.mkIf config.jetbrains.enable {
    environment.systemPackages = with pkgs; [
      jetbrains.rust-rover
      jetbrains.datagrip
    ];
  };
}
