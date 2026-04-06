# Steam, GameScope, GameMode, and Minecraft.
{den, ...}: {
  den.aspects.gaming = {
    nixos = {
      pkgs,
      lib,
      config,
      ...
    }: {
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

      programs.gamescope = {
        enable = true;
        capSysNice = true;
        args = [
          "-W 3840"
          "-H 2160"
          "-w 3840"
          "-h 2160"
          "-r 60"
          "-f"
          "--adaptive-sync"
          "--hdr-enabled"
          "--rt"
        ];
      };

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
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
      };

      programs.gamemode.enable = true;

      environment.sessionVariables = {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
      };
    };

    # Sub-aspect for Minecraft
    provides.minecraft = {
      nixos = {pkgs, ...}: {
        environment.systemPackages = with pkgs; [
          prismlauncher
          (makeDesktopItem {
            name = "prismlauncher-nvidia";
            desktopName = "Prism Launcher (Nvidia)";
            comment = "Minecraft instances using nvidia";
            exec = "nvidia-offload prismlauncher %U";
            icon = "org.prismlauncher.PrismLauncher";
            categories = ["Game"];
            prefersNonDefaultGPU = true;
          })
        ];
      };
    };
  };
}
