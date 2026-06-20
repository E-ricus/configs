# Host aspect for thinkpad-work — Intel ThinkPad, Secure Boot, disko
{den, ...}: {
  den.hosts.x86_64-linux.thinkpad-work = {
    display.scale = 1.50;
    users.ericus = {};
  };

  den.aspects.thinkpad-work = {
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
      den.aspects.emacs
    ];

    nixos = {...}: {
      imports = [./_hardware.nix];

      # TODO: This was done by a clanker, and kinda works, but I gotta chek it deeper
      # Force the Speaker profile on the sof-hda-dsp card so internal speakers
      # are always available (the default auto-profile wrongly picks Headphones
      # even when nothing is plugged in, hiding the Speaker sink).
      services.pipewire.wireplumber.extraConfig."51-thinkpad-speaker-profile" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              {
                "device.name" = "~alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic";
              }
            ];
            actions = {
              update-props = {
                "device.profile" = "HiFi (HDMI1, HDMI2, HDMI3, Mic1, Mic2, Speaker)";
              };
            };
          }
        ];
      };

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
