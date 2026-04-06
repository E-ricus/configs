# Host aspect for legion-personal — AMD + NVIDIA hybrid GPU, gaming, niri + DMS.
{den, ...}: {
  den.hosts.x86_64-linux.legion-personal = {
    scale = 2.0;
    users.ericus = {};
  };

  den.aspects.legion-personal = {
    includes = [
      den.provides.hostname
      # NixOS-only aspects (no homeManager)
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

    # Host-specific home-manager overrides (via mutual-provider → forwarded to users)
    provides.to-users.homeManager = {...}: {
      programs.niri.settings.outputs."eDP-1".scale = 2.0;
    };
  };
}
