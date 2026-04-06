# QEMU/KVM virtualization + declarative Windows 11 VM via NixVirt.
{
  den,
  inputs,
  ...
}: let
  nixvirtModule = inputs.NixVirt.nixosModules.default;
  nixvirt = inputs.NixVirt;
in {
  den.aspects.virtualization = {
    nixos = {
      pkgs,
      lib,
      ...
    }: {
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = lib.mkDefault pkgs.qemu_kvm;
          runAsRoot = false;
          swtpm.enable = true;
        };
      };

      virtualisation.spiceUSBRedirection.enable = true;
      programs.virt-manager.enable = true;

      environment.systemPackages = with pkgs; [
        virt-viewer
        spice
        spice-gtk
        spice-protocol
        virtio-win
        win-spice
      ];

      # TODO: How to pass the user with den
      users.users.ericus.extraGroups = ["libvirtd"];

      networking.firewall.interfaces."virbr0".allowedTCPPortRanges = [
        {
          from = 1;
          to = 65535;
        }
      ];

      virtualisation.libvirtd.onBoot = "ignore";
      virtualisation.libvirtd.onShutdown = "shutdown";

      # Fix: upstream service hardcodes /usr/bin/sh which doesn't exist on NixOS.
      systemd.services.virt-secret-init-encryption.serviceConfig.ExecStart = let
        script = pkgs.writeShellScript "virt-secret-init-encryption" ''
          umask 0077 && (dd if=/dev/random status=none bs=32 count=1 | ${pkgs.systemd}/bin/systemd-creds encrypt --name=secrets-encryption-key - /var/lib/libvirt/secrets/secrets-encryption-key)
        '';
      in
        lib.mkForce ["" script];
    };
  };

  # Windows 11 VM aspect.
  # Note: host must also include den.aspects.virtualization.
  den.aspects.windows-vm = {
    nixos = {lib, ...}: let
      storagePath = "/var/lib/libvirt/images/windows-vm";
      poolUUID = "4191d432-1897-4b2b-a02f-e41811f0298b";
      networkUUID = "3e9f8f79-67b8-4bd3-aeb9-3a50be2d610f";
      domainUUID = "8f1a52ac-750b-45ca-b939-0a456a178a78";
    in {
      imports = [nixvirtModule];

      systemd.tmpfiles.rules = [
        "d ${storagePath} 0755 root root -"
        "d /var/lib/libvirt/isos 0755 root root -"
        "d /var/lib/swtpm-localca 0750 tss tss -"
        "d /var/log/swtpm/libvirt/qemu 0750 tss tss -"
      ];

      virtualisation.libvirt = {
        enable = true;
        swtpm.enable = true;
        verbose = false;
        connections."qemu:///system" = {
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
                      count = 100;
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
          domains = [
            {
              definition = nixvirt.lib.domain.writeXML (nixvirt.lib.domain.templates.windows {
                name = "windows-vm";
                uuid = domainUUID;
                memory = {
                  count = 15;
                  unit = "GiB";
                };
                storage_vol = {
                  pool = "windows-vm";
                  volume = "windows-vm.qcow2";
                };
                install_vol = "/var/lib/libvirt/isos/windows11.iso";
                nvram_path = "${storagePath}/windows-vm.nvram";
                virtio_net = true;
                virtio_drive = true;
                virtio_video = false;
                install_virtio = true;
              });
              active = null;
            }
          ];
        };
      };
    };
  };
}
