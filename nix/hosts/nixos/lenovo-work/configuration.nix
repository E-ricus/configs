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

  # Firmware does not bridge usb charging as AC
  boot.blacklistedKernelModules = ["ac"];
  # Hibernation support
  # resumeDevice points to the opened LUKS volume defined in disko.nix
  boot.resumeDevice = "/dev/mapper/crypted";
  # resume_offset is required for btrfs swapfiles. Get the value by running:
  #   sudo btrfs inspect-internal map-swapfile -r /.swapvol/swapfile
  boot.kernelParams = ["resume_offset=41286002"];

  # Suspend-then-hibernate: suspend to RAM first, auto-hibernate after x min
  systemd.sleep.settings.Sleep.HibernateDelaySec = "15min";

  # Lid and power button behavior
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend";
    HandlePowerKey = "hibernate";
    HandlePowerKeyLongPress = "poweroff";
  };

  # Taken from nixos-hardware
  services.fstrim.enable = true;

  # User account
  users.users.${user} = {
    isNormalUser = true;
    description = "Eric";
    extraGroups = ["networkmanager" "wheel" "video" "audio" "plugdev"];
    shell = pkgs.fish;
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
  # Uses pam-fprint-grosshack for parallel auth: fingerprint and password
  # prompts are active simultaneously — whichever succeeds first wins.
  fingerprint-config.enable = true;

  # Backlight control - udev rules for video group write access
  hardware.brillo.enable = true;

  keyboards-config.zsa.enable = true;
  jetbrains.enable = true;
  virtualization-config.enable = true;
  windows-vm.enable = true;
  work.enable = true;
}
