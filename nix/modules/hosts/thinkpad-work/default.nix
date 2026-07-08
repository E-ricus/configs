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
      den.aspects.keyboards-qmk
      den.aspects.jetbrains
      den.aspects.virtualization
      den.aspects.windows-vm
      den.aspects.work-tools
      den.aspects.vpn
      den.aspects.emacs
    ];

    nixos = {...}: {
      imports = [./_hardware.nix];

      # sof-hda-dsp (UCM2) exposes Speaker and Headphones as two separate,
      # mutually-exclusive analog profiles (each carries its own analog sink;
      # both also contain all the HDMI sinks). The Headphones profile has a
      # higher built-in priority (10300 > 10200), so on any card re-evaluation
      # — e.g. plugging in HDMI — WirePlumber's auto-profile policy would jump
      # to the Headphones profile and drop the Speaker sink, killing speaker
      # audio even with nothing in the headphone jack. That was the annoying
      # HDMI-steals-the-speakers bug.
      #
      # Fix: pin Speaker as the initial profile AND disable automatic profile
      # re-selection (api.acp.auto-profile = false) so the policy stops chasing
      # the higher-priority Headphones profile on unrelated events like HDMI
      # hotplug. WirePlumber still remembers and restores manual choices.
      #
      # Trade-off (hardware limitation): because Speaker/Headphones are distinct
      # profiles, the wired headphone jack does NOT auto-switch with this
      # setting — switch to the Headphones profile manually in the audio menu
      # when you plug in. The manual switch is honored and persists. This is the
      # deliberate choice: reliable speakers (HDMI-proof) over automatic jack
      # switching.
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
                "api.acp.auto-profile" = false;
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
