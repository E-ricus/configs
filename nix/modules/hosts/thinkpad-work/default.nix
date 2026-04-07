# Host aspect for thinkpad-work — Intel ThinkPad, Secure Boot, disko
{den, ...}: {
  den.hosts.x86_64-linux.thinkpad-work = {
    display.scale = 1.75;
    users.ericus = {};
  };

  den.aspects.thinkpad-work = {
    # Push desktop homeManager config to all users on this host.
    provides.to-users = {
      homeManager.imports = [
        den.aspects.wayland.homeManager
        den.aspects.dms.homeManager
      ];
    };

    includes = [
      den.provides.hostname
      # NixOS-only aspects
      den.aspects.base-system
      den.aspects.locale
      den.aspects.boot-lanzaboote
      den.aspects.disko-luks-btrfs
      den.aspects.intel-graphics
      den.aspects.media
      den.aspects.fingerprint
      den.aspects.keyboards-zsa
      den.aspects.jetbrains
      den.aspects.virtualization
      den.aspects.windows-vm
      den.aspects.work-tools
      den.aspects.vpn
      # Desktop
      den.aspects.niri-dms
    ];

    nixos = {pkgs, ...}: {
      imports = [./_hardware.nix];

      # Disko: host-specific disk device and swap size
      diskoConfig.device = "/dev/nvme0n1";
      diskoConfig.swapSize = "75G";

      # LUKS / initrd — required for TPM2 unlock
      boot.initrd.systemd.enable = true;

      # TPM2
      security.tpm2 = {
        enable = true;
        pkcs11.enable = true;
        tctiEnvironment.enable = true;
      };

      # Firmware does not bridge usb charging as AC
      boot.blacklistedKernelModules = ["ac"];

      # Hibernation support
      boot.resumeDevice = "/dev/mapper/crypted";
      boot.kernelParams = ["resume_offset=41286002"];

      # Suspend-then-hibernate
      systemd.sleep.settings.Sleep.HibernateDelaySec = "15min";

      # Lid and power button behavior
      services.logind.settings.Login = {
        HandleLidSwitch = "suspend-then-hibernate";
        HandleLidSwitchExternalPower = "suspend";
        HandlePowerKey = "hibernate";
        HandlePowerKeyLongPress = "poweroff";
      };

      services.fstrim.enable = true;
      hardware.brillo.enable = true;
    };
  };
}
