{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    editors.enable = lib.mkEnableOption "enables editors";
    editors.zed.enable = lib.mkEnableOption "enables zed editor";
  };

  config = lib.mkIf config.editors.enable {
    # Enabled by default if editors is enabled, can be disabled
    editors.zed.enable = lib.mkDefault true;
    home.packages = with pkgs; [
      neovim # not ready to give my config to nix
      # needed for neovim
      luajitPackages.luarocks-nix
    ];

    programs.zed-editor = lib.mkIf config.editors.zed.enable {
      enable = true;
    };
  };
}
