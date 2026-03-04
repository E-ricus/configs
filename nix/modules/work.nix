{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    work.enable =
      lib.mkEnableOption "enables work packages and tools";
  };

  config = lib.mkIf config.work.enable {
    environment.systemPackages = with pkgs; [
      slack
      graphite-cli
      awscli2
      postgresql
      insomnia
    ];
    # For slack in wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
