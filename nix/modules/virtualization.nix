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

    # Allow VMs on the NAT bridge to reach host services (e.g., localhost:8080).
    # This is safe since virbr0 is a private NAT network only VMs use.
    networking.firewall.interfaces."virbr0".allowedTCPPortRanges = [
      {from = 1; to = 65535;}
    ];

    # Optional: Enable dnsmasq for VM networking
    virtualisation.libvirtd.onBoot = "ignore"; # Don't auto-start VMs on boot
    virtualisation.libvirtd.onShutdown = "shutdown"; # Gracefully shutdown VMs

    # Fix: upstream service hardcodes /usr/bin/sh which doesn't exist on NixOS.
    # ExecStart in drop-ins requires clearing the original value first (empty string),
    # then setting the new one. mkForce only affects NixOS module merging, not systemd.
    systemd.services.virt-secret-init-encryption.serviceConfig.ExecStart = let
      script = pkgs.writeShellScript "virt-secret-init-encryption" ''
        umask 0077 && (dd if=/dev/random status=none bs=32 count=1 | ${pkgs.systemd}/bin/systemd-creds encrypt --name=secrets-encryption-key - /var/lib/libvirt/secrets/secrets-encryption-key)
      '';
    in
      lib.mkForce ["" script];
    ## delete this block when this issue: https://github.com/NixOS/nixpkgs/issues/496836 is resolved
  };
}
