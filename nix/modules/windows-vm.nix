# Declarative Windows 11 VM via NixVirt.
#
# Usage:
#   1. Place the Windows 11 ISO at /var/lib/libvirt/isos/windows11.iso
#      (or set windows-vm.isoPath to a custom location).
#      The path must be readable by the qemu user — avoid /home paths
#      when libvirtd runs QEMU as non-root.
#
#   2. Rebuild: sudo nixos-rebuild switch --flake .#<host>
#
#   3. Open virt-manager, start the "windows-vm" domain.
#
#   4. During Windows installation, the disk and network won't be
#      visible because Windows lacks VirtIO drivers. The VirtIO driver
#      ISO is already attached as a second CDROM (drive E:).
#
#      To load the storage driver (required to see the disk):
#        - Click "Load driver" > Browse
#        - Navigate to E:\viostor\w11\amd64
#        - Select the "Red Hat VirtIO SCSI controller" driver
#        - The 100 GB disk will then appear for installation
#
#      To load the network driver (required for internet):
#        - Click "Load driver" > Browse
#        - Navigate to E:\NetKVM\w11\amd64
#        - Select the "Red Hat VirtIO Ethernet Adapter" driver
#
#      Other useful drivers on the same ISO (all under w11\amd64):
#        - E:\Balloon   — memory ballooning
#        - E:\vioscsi   — SCSI controller
#        - E:\vioser    — serial port
#        - E:\qxl       — display adapter
#
#   5. After installation, open File Explorer > E: drive and run
#      virtio-win-guest-tools.exe — this single installer bundles all
#      VirtIO drivers (balloon, serial, display, SCSI, etc.) plus the
#      SPICE guest agent (clipboard sharing, auto-resolution).
#      No need to manually install individual drivers from step 4.
#
#   6. Enable SSH access from the host (inside the Windows VM):
#      a. Open PowerShell as Administrator and run:
#           Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
#           Start-Service sshd
#           Set-Service -Name sshd -StartupType Automatic
#      b. Allow SSH through Windows Firewall:
#           New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
#      c. Find the VM's IP from the host:
#           sudo virsh net-dhcp-leases default
#         The VM has a static DHCP reservation at 192.168.122.129.
#
#   7. File transfer between host and VM (from the host terminal):
#        scp myfile.txt <user>@192.168.122.129:C:/Users/<user>/Desktop/
#        scp <user>@192.168.122.129:C:/Users/<user>/Documents/file.txt ./
#      To avoid typing the password each time: ssh-copy-id <user>@192.168.122.129
#
#   8. Reaching host services from the VM:
#      The host is reachable at 192.168.122.1 from inside the VM.
#      For example, a service on host localhost:3000 is accessible at:
#        http://192.168.122.1:3000
#      The virtualization module opens the host firewall on virbr0 for this.
#      VM traffic goes through the host network stack, including VPNs.
#
#   9. Once done, set isoPath = null and rebuild to detach the
#      installer ISO from the VM definition if wanted.
{
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.windows-vm;
  nixvirt = inputs.NixVirt;

  storagePath = cfg.storagePath;

  poolUUID = "4191d432-1897-4b2b-a02f-e41811f0298b";
  networkUUID = "3e9f8f79-67b8-4bd3-aeb9-3a50be2d610f";
  domainUUID = "8f1a52ac-750b-45ca-b939-0a456a178a78";
in {
  imports = [inputs.NixVirt.nixosModules.default];

  options.windows-vm = {
    enable = lib.mkEnableOption "declarative Windows 11 VM via NixVirt";

    isoPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "/var/lib/libvirt/isos/windows11.iso";
      description = ''
        Path to the Windows 11 ISO file (as a string, not a Nix path).
        Must be readable by the qemu user (avoid paths under /home
        when libvirtd runs qemu as non-root).
        Set to null after installation is complete to detach the installer ISO.
        The build succeeds even if this file doesn't exist yet —
        the VM just won't boot until the ISO is in place.
      '';
      example = "/var/lib/libvirt/isos/windows11.iso";
    };

    storagePath = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/libvirt/images/windows-vm";
      description = "Directory to store the VM disk image and NVRAM.";
    };

    memoryGiB = lib.mkOption {
      type = lib.types.int;
      default = 15;
      description = "Amount of RAM allocated to the VM in GiB.";
    };

    diskSizeGB = lib.mkOption {
      type = lib.types.int;
      default = 100;
      description = "Size of the VM disk in GB (thin-provisioned QCOW2).";
    };

    vcpus = lib.mkOption {
      type = lib.types.int;
      default = 8;
      description = "Number of virtual CPUs allocated to the VM.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure the virtualization base module is also enabled
    virtualization-config.enable = true;

    # Ensure the storage directory exists
    systemd.tmpfiles.rules = [
      "d ${storagePath} 0755 root root -"
      "d /var/lib/libvirt/isos 0755 root root -"
      "d /var/lib/swtpm-localca 0750 tss tss -"
      "d /var/log/swtpm/libvirt/qemu 0750 tss tss -"
    ];

    # NixVirt configuration
    virtualisation.libvirt = {
      enable = true;
      swtpm.enable = true; # Required for Windows 11 TPM 2.0
      verbose = false;

      connections."qemu:///system" = {
        # Storage pool for VM images
        pools = [
          {
            definition = nixvirt.lib.pool.writeXML {
              name = "windows-vm";
              uuid = poolUUID;
              type = "dir";
              target = {path = storagePath;};
            };
            active = true;
            volumes = [
              {
                definition = nixvirt.lib.volume.writeXML {
                  name = "windows-vm.qcow2";
                  capacity = {
                    count = cfg.diskSizeGB;
                    unit = "GB";
                  };
                  target = {
                    format = {type = "qcow2";};
                  };
                };
              }
            ];
          }
        ];

        # NAT network bridge for the VM with static DHCP reservation
        networks = [
          {
            definition = nixvirt.lib.network.writeXML {
              name = "default";
              uuid = networkUUID;
              forward = {
                mode = "nat";
                nat = {
                  port = {
                    start = 1024;
                    end = 65535;
                  };
                };
              };
              bridge = {name = "virbr0";};
              ip = {
                address = "192.168.122.1";
                netmask = "255.255.255.0";
                dhcp = {
                  range = {
                    start = "192.168.122.2";
                    end = "192.168.122.254";
                  };
                  host = {
                    mac = "52:54:00:62:cc:b0";
                    name = "windows-vm";
                    ip = "192.168.122.129";
                  };
                };
              };
            };
            active = true;
          }
        ];

        # Windows 11 VM domain
        domains = [
          {
            definition = nixvirt.lib.domain.writeXML (nixvirt.lib.domain.templates.windows {
              name = "windows-vm";
              uuid = domainUUID;
              memory = {
                count = cfg.memoryGiB;
                unit = "GiB";
              };
              storage_vol = {
                pool = "windows-vm";
                volume = "windows-vm.qcow2";
              };
              install_vol =
                if cfg.isoPath != null
                then cfg.isoPath
                else null;
              nvram_path = "${storagePath}/windows-vm.nvram";
              virtio_net = true; # Better network performance (needs VirtIO driver during install)
              virtio_drive = true; # Better disk performance (needs VirtIO driver during install)
              virtio_video = false; # VirtIO GPU not great right now
              install_virtio = true; # Attach VirtIO driver ISO for Windows installation
            });
            # Don't auto-start/stop — manage via virt-manager
            active = null;
          }
        ];
      };
    };
  };
}
