{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.hybrid-gpu;
in {
  options = {
    hybrid-gpu = {
      enable = lib.mkEnableOption "hybrid GPU configuration (AMD iGPU + NVIDIA dGPU)";

      # PCI bus IDs for the GPUs
      amdBusId = lib.mkOption {
        type = lib.types.str;
        default = "PCI:5:0:0";
        description = ''
          PCI bus ID for the AMD integrated GPU.
          Default is PCI:5:0:0 for single-drive setups.
          Use PCI:6:0:0 for dual-drive configurations.
          Find yours with: lspci | grep VGA
        '';
      };

      nvidiaBusId = lib.mkOption {
        type = lib.types.str;
        default = "PCI:1:0:0";
        description = ''
          PCI bus ID for the NVIDIA discrete GPU.
          Find yours with: lspci | grep VGA
        '';
      };
      # Enable nvidia-only mode specialization
      nvidiaOnly.enable = lib.mkEnableOption "nvidia-only mode specialization";
    };
  };

  config = lib.mkIf cfg.enable {
    # HYBRID MODE (Default) - AMD Primary with NVIDIA Offload
    # REMINDER: change to mkDefault if I need overwrite per machine, shouldn't need it, but just in case
    services.xserver.videoDrivers = ["modesetting" "nvidia"];
    # Enable AMD GPU hardware acceleration
    hardware.amdgpu = {
      initrd.enable = true;
      opencl.enable = lib.mkDefault true;
    };

    # Configure NVIDIA drivers and PRIME
    hardware.nvidia = {
      open = true;
      nvidiaSettings = true;
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        # This allows the GPU to be completely powered off when not in use
        finegrained = true;
      };

      # NVIDIA PRIME configuration - Offload mode
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };

        # Set PCI bus IDs
        amdgpuBusId = cfg.amdBusId;
        nvidiaBusId = cfg.nvidiaBusId;
      };
    };

    # Add helpful utilities
    environment.systemPackages = with pkgs; [
      # GPU monitoring and management
      nvtopPackages.full # Monitor GPU usage (supports NVIDIA, AMD, Intel)
      lshw # List hardware including GPUs
      pciutils # lspci command for finding PCI bus IDs
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
    specialisation = {
      # NVIDIA-ONLY MODE
      nvidia-only = lib.mkIf cfg.nvidiaOnly.enable {
        inheritParentConfig = true;
        configuration = {
          system.nixos.tags = ["nvidia-only"];
          services.xserver.videoDrivers = lib.mkForce ["nvidia"];
          hardware.amdgpu = lib.mkIf (lib.hasAttr "amdgpu" config.hardware) {
            initrd.enable = lib.mkForce false;
            opencl.enable = lib.mkForce false;
          };

          # Disable NVIDIA PRIME offload - use NVIDIA directly
          hardware.nvidia = {
            powerManagement = {
              enable = lib.mkForce false;
              finegrained = lib.mkForce false;
            };
            # Disable PRIME
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
