# The Oh Keycaps build uses controllers with the Atmel DFU bootloader
# (03eb:2ff4), not Caterina as the promicro keyboard.json assumes.
# This makes `qmk flash` use dfu-programmer instead of waiting for a
# Caterina ttyACM serial port that never appears.
BOOTLOADER = atmel-dfu
