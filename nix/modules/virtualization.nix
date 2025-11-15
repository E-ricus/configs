{
  config,
  pkgs,
  lib,
  user,
  ...
}: {
  options = {
    virtualization-config.enable =
      lib.mkEnableOption "enables virtualization with QEMU/KVM";
  };

  config = lib.mkIf config.virtualization-config.enable {
    # Enable QEMU/KVM virtualization
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
        swtpm.enable = true; # TPM emulation for Windows 11
      };
    };

    # Enable USB redirection for VMs
    virtualisation.spiceUSBRedirection.enable = true;

    # Install virt-manager and related tools
    programs.virt-manager.enable = true;

    environment.systemPackages = with pkgs; [
      virt-viewer # Remote viewer for VMs
      spice # SPICE protocol for better graphics
      spice-gtk # SPICE client
      spice-protocol
      virtio-win # Windows VirtIO drivers ISO
      win-spice # Windows SPICE tools
    ];

    # Add your user to libvirtd group
    users.users.${user}.extraGroups = ["libvirtd"];

    # Optional: Enable dnsmasq for VM networking
    virtualisation.libvirtd.onBoot = "ignore"; # Don't auto-start VMs on boot
    virtualisation.libvirtd.onShutdown = "shutdown"; # Gracefully shutdown VMs
  };
}
