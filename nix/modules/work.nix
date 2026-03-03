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

  config = lib.mkIf config.jetbrains.enable {
    environment.systemPackages = with pkgs; [
      slack
      graphite-cli
      awscli2
    ];
  };
}
