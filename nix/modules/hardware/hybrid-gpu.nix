# AMD iGPU + NVIDIA dGPU PRIME offload configuration.
# This aspect is host-specific — bus IDs are set in the host aspect.
{den, ...}: {
  den.aspects.hybrid-gpu = {
    nixos = {
      pkgs,
      lib,
      config,
      ...
    }: {
      services.xserver.videoDrivers = ["modesetting" "nvidia"];

      hardware.amdgpu = {
        initrd.enable = true;
        opencl.enable = lib.mkDefault true;
      };

      hardware.nvidia = {
        open = true;
        nvidiaSettings = true;
        modesetting.enable = true;
        powerManagement = {
          enable = true;
          finegrained = true;
        };
        prime = {
          offload = {
            enable = true;
            enableOffloadCmd = true;
          };
          # Bus IDs must be set in the host aspect:
          #   amdgpuBusId = "PCI:5:0:0";
          #   nvidiaBusId = "PCI:1:0:0";
        };
      };

      environment.systemPackages = with pkgs; [
        nvtopPackages.full
        lshw
        pciutils
        (pkgs.writeShellScriptBin "nvidia-check" ''
          #!/usr/bin/env bash
          echo "Nvidia GPU check"
          echo ""
          GPU="0000:01:00.0"
          echo "runtime_status:"
          cat /sys/bus/pci/devices/$GPU/power/runtime_status
          echo "power_state:"
          cat /sys/bus/pci/devices/$GPU/power_state
          echo "driver bound?"
          ls -l /sys/bus/pci/devices/$GPU/driver 2>/dev/null || echo "None (unbound)"
        '')
      ];

      specialisation.nvidia-only = {
        inheritParentConfig = true;
        configuration = {
          system.nixos.tags = ["nvidia-only"];
          services.xserver.videoDrivers = lib.mkForce ["nvidia"];
          hardware.amdgpu = lib.mkIf (lib.hasAttr "amdgpu" config.hardware) {
            initrd.enable = lib.mkForce false;
            opencl.enable = lib.mkForce false;
          };
          hardware.nvidia = {
            powerManagement = {
              enable = lib.mkForce false;
              finegrained = lib.mkForce false;
            };
            prime = {
              offload.enable = lib.mkForce false;
              offload.enableOffloadCmd = lib.mkForce false;
              sync.enable = lib.mkForce false;
              reverseSync.enable = lib.mkForce false;
            };
          };
        };
      };
    };
  };
}
