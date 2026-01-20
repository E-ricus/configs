{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    gaming-config.enable =
      lib.mkEnableOption "enables gaming configuration with Steam and related tools";
  };

  config = lib.mkIf config.gaming-config.enable {
    # Gaming packages
    environment.systemPackages = with pkgs; [
      mangohud
      protonup-ng
      heroic

      # Steam GameScope launcher
      (makeDesktopItem {
        name = "steam-gamescope";
        desktopName = "Steam (GameScope)";
        comment = "Launch Steam in GameScope for optimized gaming";
        exec = "/run/wrappers/bin/gamescope -e -- steam -gamepadui";
        icon = "steam";
        categories = ["Game"];
        prefersNonDefaultGPU = true;
      })
    ];

    # GameScope configuration
    programs.gamescope = {
      enable = true;
      capSysNice = true;
      args = [
        "-W 3840" # Width
        "-H 2160" # Height
        "-w 3840" # Game width
        "-h 2160" # Game height
        "-r 60" # Refresh rate (adjust to your display's max)
        "-f" # Fullscreen
        "--adaptive-sync"
        "--hdr-enabled"
        "--rt"
      ];
    };

    # Steam configuration
    # Enable in settings -> interface -> Enable GPU acceleration for web views, to get Bigpicture mode working withoug lag
    programs.steam = {
      enable = true;
      package = pkgs.steam.override {
        extraEnv = lib.mkIf (config.hardware.nvidia.prime.offload.enable or false) {
          __NV_PRIME_RENDER_OFFLOAD = "1";
          __VK_LAYER_NV_optimus = "NVIDIA_only";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        };
      };
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game transfers
    };

    # GameMode configuration
    programs.gamemode.enable = true;

    # Steam environment variables
    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    };
  };
}
