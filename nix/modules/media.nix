{
  config,
  lib,
  ...
}: {
  options = {
    media-config = {
      audio.enable = lib.mkEnableOption "enables audio with PipeWire";
      bluetooth.enable = lib.mkEnableOption "enables Bluetooth support";
    };
  };

  config = lib.mkMerge [
    # Audio configuration
    (lib.mkIf config.media-config.audio.enable {
      # Enable sound with PipeWire
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
    })

    # Bluetooth configuration
    (lib.mkIf config.media-config.bluetooth.enable {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            # Shows battery charge of connected devices on supported
            # Bluetooth adapters. Defaults to 'false'.
            Experimental = true;
            # When enabled other devices can connect faster to us, however
            # the tradeoff is increased power consumption. Defaults to
            # 'false'.
            FastConnectable = true;
          };
          Policy = {
            # Enable all controllers when they are found. This includes
            # adapters present on start as well as adapters that are plugged
            # in later on. Defaults to 'true'.
            AutoEnable = true;
          };
        };
      };
    })
  ];
}
