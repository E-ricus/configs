# Disko aspect — LUKS-encrypted btrfs with swap.
# Layout: GPT -> ESP (512M) + LUKS -> btrfs (root, home, nix, swap)
#
# Host-specific values are set via NixOS options:
#   diskoConfig.device  — disk device path (default: /dev/nvme0n1)
#   diskoConfig.swapSize — swap file size (default: 75G)
{
  den,
  inputs,
  ...
}: let
  diskoModule = inputs.disko.nixosModules.disko;
in {
  den.aspects.disko-luks-btrfs = {
    nixos = {
      lib,
      config,
      ...
    }: let
      cfg = config.diskoConfig;
    in {
      imports = [diskoModule];

      options.diskoConfig = {
        device = lib.mkOption {
          type = lib.types.str;
          default = "/dev/nvme0n1";
          description = "Disk device path for disko partitioning";
        };
        swapSize = lib.mkOption {
          type = lib.types.str;
          default = "75G";
          description = "Swap file size (e.g. 75G, 32G)";
        };
      };

      config.disko.devices = {
        disk.vdb = {
          type = "disk";
          device = lib.mkDefault cfg.device;
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "512M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = ["defaults"];
                };
              };
              luks = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "crypted";
                  settings = {
                    allowDiscards = true;
                  };
                  content = {
                    type = "btrfs";
                    extraArgs = ["-f"];
                    subvolumes = {
                      "/root" = {
                        mountpoint = "/";
                        mountOptions = ["compress=zstd" "noatime"];
                      };
                      "/home" = {
                        mountpoint = "/home";
                        mountOptions = ["compress=zstd" "noatime"];
                      };
                      "/nix" = {
                        mountpoint = "/nix";
                        mountOptions = ["compress=zstd" "noatime"];
                      };
                      "/swap" = {
                        mountpoint = "/.swapvol";
                        swap.swapfile.size = cfg.swapSize;
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
