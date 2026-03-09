{
  pkgs,
  user,
  ...
}: {
  imports = [./disko.nix];

  # Bootloader - Secure Boot via lanzaboote
  boot-config.type = "lanzaboote";

  # LUKS / initrd - required for TPM2 unlock
  boot.initrd.systemd.enable = true;

  # TPM2
  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
  };

  # Hibernation support
  # resumeDevice points to the opened LUKS volume defined in disko.nix
  boot.resumeDevice = "/dev/mapper/crypted";
  # resume_offset is required for btrfs swapfiles. Get the value by running:
  #   sudo btrfs inspect-internal map-swapfile -r /.swapvol/swapfile
  boot.kernelParams = ["resume_offset=41286002"];

  # Suspend-then-hibernate: suspend to RAM first, auto-hibernate after 30 min
  systemd.sleep.settings.Sleep.HibernateDelaySec = "30min";

  # Lid and power button behavior
  services.logind.settings.Login = {
    LidSwitch = "suspend-then-hibernate";
    PowerKey = "hibernate";
    PowerKeyLongPress = "poweroff";
  };

  # Taken from nixos-hardware
  services.fstrim.enable = true;

  # User account
  users.users.${user} = {
    isNormalUser = true;
    description = "Eric";
    extraGroups = ["networkmanager" "wheel" "video" "audio" "plugdev"];
    shell = pkgs.nushell;
  };

  # Enable modules
  desktop-wayland = {
    enable = true;
    compositor = "niri";
  };
  graphics-config = {
    enable = true;
    intel = {
      enable = true;
      driver = "xe";
    };
  };
  media-config = {
    audio.enable = true;
    bluetooth.enable = true;
  };

  # Fingerprint (Synaptics 06cb:00f9, natively supported by libfprint)
  # Is sometimes flaky, and when using an external monitor and lid is close I don't have the sensor.
  # TODO: Have password work in paralel
  services.fprintd.enable = false;
  security.pam.services = {
    sudo.fprintAuth = true;
    hyprlock.fprintAuth = true;
    swaylock.fprintAuth = true;
    gtklock.fprintAuth = true;
  };

  # Backlight control - udev rules for video group write access
  hardware.brillo.enable = true;

  keyboards-config.zsa.enable = true;
  jetbrains.enable = true;
  virtualization-config.enable = true;
  windows-vm.enable = true;
  work.enable = true;
}
