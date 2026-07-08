# QMK toolchain + flashing support for the Dactyl Manuform 6x6 (Pro Micro / Caterina).
#
# Workflow:
#   qmk setup                                                    # one-time, clones ~/qmk_firmware
#   <symlink personal keymap>                                    # see configs/qmk/README.md
#   qmk compile -kb handwired/dactyl_manuform/6x6/promicro -km ericus
#   qmk flash   -kb handwired/dactyl_manuform/6x6/promicro -km ericus
{den, ...}: {
  den.aspects.keyboards-qmk = {
    nixos = {pkgs, ...}: {
      # Packages available system-wide for building/flashing firmware
      environment.systemPackages = with pkgs; [
        qmk # qmk CLI: setup, compile, flash
        avrdude # flasher for Caterina/Pro Micro (ATmega32U4)
        dfu-programmer # flasher for Atmel DFU bootloader
        dos2unix # required by `qmk doctor`
      ];

      # udev rules so flashing works without root.
      services.udev.extraRules = ''
        # Atmel DFU bootloader (Elite-C / Oh Keycaps controllers) — what this board actually uses
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ff4", MODE:="0666"
        # Atmel/Arduino-style Caterina bootloaders (Pro Micro & clones)
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0036", MODE:="0666"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="1b4f", ATTRS{idProduct}=="9205", MODE:="0666"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="1b4f", ATTRS{idProduct}=="9203", MODE:="0666"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="0483", MODE:="0666"
        # ttyACM device that appears while in bootloader
        KERNEL=="ttyACM*", ATTRS{idVendor}=="2341", MODE:="0666", GROUP="plugdev"
        KERNEL=="ttyACM*", ATTRS{idVendor}=="1b4f", MODE:="0666", GROUP="plugdev"
        # Running keyboard (tshort Dactyl-Manuform) accessible to plugdev
        KERNEL=="hidraw*", ATTRS{idVendor}=="444d", MODE="0664", GROUP="plugdev"
      '';

      users.groups.plugdev = {};
    };
  };
}
