# Host: legion-personal
{
  inputs,
  config,
  ...
}: {
  flake.nixosConfigurations.legion-personal = inputs.nixpkgs.lib.nixosSystem {
    modules = with config.flake.modules.nixos; [
      defaults
      ericus
      base-system
      locale
      boot-systemd
      graphics-32bit
      hybrid-gpu
      media
      gaming
      gaming-minecraft
      fingerprint-elan
      keyboards-zsa
      keyboards-qmk
      vpn
      vpn-mullvad

      ({...}: {
        networking.hostName = "legion-personal";
        my.display.scale = 1.75;

        imports = [./_hardware.nix];

        services.fstrim.enable = true;
        hardware.brillo.enable = true;

        # NVIDIA PRIME bus IDs (host-specific)
        hardware.nvidia.prime = {
          amdgpuBusId = "PCI:5:0:0";
          nvidiaBusId = "PCI:1:0:0";
        };
      })
    ];
  };
}
