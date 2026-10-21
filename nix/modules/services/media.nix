# Audio (PipeWire) and Bluetooth aspects.
{...}: {
  flake.modules.nixos.media = {pkgs, ...}: {
    # PipeWire audio
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      extraConfig.pipewire."10-clock-rates" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.allowed-rates" = [44100 48000 88200 96000 192000];
        };
      };
    };

    # Bluetooth
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
          FastConnectable = true;
        };
        Policy = {
          AutoEnable = true;
        };
      };
    };

    # ── Auto-trust paired Bluetooth devices ──────────────────────────
    # BlueZ only auto-authorizes *incoming* profile connections from
    # devices marked Trusted. Pairing via bluetoothctl or a bar widget
    # (unlike GNOME/KDE, which set trust on pairing) leaves devices
    # untrusted. When such headphones initiate the reconnect themselves,
    # the incoming A2DP setup stalls waiting for agent authorization and
    # bluetoothd's own outgoing attempt collides with it. Failure
    # signature: "a2dp-sink profile connect failed ...: Device or
    # resource busy" in bluetoothd logs, and the PipeWire card stuck on
    # the off/audio-gateway profile with no sink to select.
    #
    # Trust is per-device state in /var/lib/bluetooth, so it cannot be
    # declared directly; instead, trust every already-paired device
    # (equivalent to what full DEs do). The timer re-runs the oneshot
    # periodically, so newly paired devices are trusted without a
    # reboot. (A path unit won't do: systemd path watches are not
    # recursive, and pairing writes to /var/lib/bluetooth/<adapter>/.)
    systemd.services.bluetooth-auto-trust = {
      description = "Mark all paired Bluetooth devices as trusted";
      after = ["bluetooth.service"];
      requires = ["bluetooth.service"];
      wantedBy = ["bluetooth.service"];
      serviceConfig = {
        Type = "oneshot";
      };
      script = ''
        ${pkgs.bluez}/bin/bluetoothctl devices Paired \
          | ${pkgs.gawk}/bin/awk '/^Device/ {print $2}' \
          | while read -r mac; do
            ${pkgs.bluez}/bin/bluetoothctl trust "$mac"
          done
      '';
    };

    systemd.timers.bluetooth-auto-trust = {
      description = "Periodically re-trust paired Bluetooth devices";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "1min";
        OnUnitActiveSec = "5min";
      };
    };
  };
}
