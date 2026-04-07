# Host aspect for legion-personal
{den, ...}: {
  den.hosts.x86_64-linux.legion-personal = {
    display.scale = 2.0;
    users.ericus = {};
  };

  den.aspects.legion-personal = {
    # Push desktop homeManager config to all users on this host.
    # mutual-provider reads provides.to-users from the host's own aspect only.
    # We return the homeManager class directly so the desktop aspects' HM
    # modules (wayland packages, noctalia swayidle/hyprlock) reach all users.
    provides.to-users = {
      homeManager.imports = [
        den.aspects.wayland.homeManager
        den.aspects.niri-noctalia.homeManager
      ];
    };

    includes = [
      den.provides.hostname
      # NixOS-only aspects
      den.aspects.base-system
      den.aspects.locale
      den.aspects.boot-systemd
      den.aspects.graphics-32bit
      den.aspects.hybrid-gpu
      den.aspects.media
      den.aspects.gaming
      den.aspects.gaming.provides.minecraft
      den.aspects.fingerprint-elan
      den.aspects.keyboards-zsa
      den.aspects.vpn
      den.aspects.vpn.provides.mullvad
      # Desktop
      den.aspects.niri-noctalia
    ];

    nixos = {pkgs, ...}: {
      imports = [./_hardware.nix];

      services.fstrim.enable = true;
      hardware.brillo.enable = true;

      # NVIDIA PRIME bus IDs (host-specific)
      hardware.nvidia.prime = {
        amdgpuBusId = "PCI:5:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };
}
