# Audio (PipeWire) and Bluetooth aspects.
{den, ...}: {
  den.aspects.media = {
    nixos = {...}: {
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

        # TODO: Fixed by clanker I have to check
        # Bluetooth audio: force headsets to connect as high-quality A2DP
        # sinks (music) instead of the "audio-gateway" profile.
        #
        # Some headsets (e.g. Marshall MONITOR II) advertise an A2DP *source*
        # endpoint in addition to the sink. WirePlumber's default roles include
        # a2dp_source, so when the headset offers to be a source the negotiation
        # resolves with the laptop as the sink — activating the "audio-gateway"
        # profile (0 playback sinks). The headset then can't be selected as an
        # output at all.
        #
        # The fix that actually works is to NOT advertise a2dp_source (or the AG
        # roles) on our side. With only a2dp_sink/hfp_hf/hsp_hs enabled, the
        # laptop is always the A2DP source and the headset becomes the sink, so
        # the a2dp-sink profile is created and auto-selected.
        wireplumber.extraConfig."51-bluez-playback-roles" = {
          "monitor.bluez.properties" = {
            "bluez5.roles" = ["a2dp_sink" "hfp_hf" "hsp_hs"];
            "bluez5.codecs" = ["sbc" "sbc_xq" "aac" "aptx" "aptx_hd" "ldac"];
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
          };
          "monitor.bluez.rules" = [
            {
              matches = [{"device.name" = "~bluez_card.*";}];
              actions = {
                update-props = {
                  # Activate the A2DP sink profile on connect, not gateway.
                  "device.profile" = "a2dp-sink";
                  # Auto-connect playback profiles so partial source-only
                  # connections get upgraded to A2DP sink.
                  "bluez5.auto-connect" = ["a2dp_sink" "hfp_hf" "hsp_hs"];
                };
              };
            }
          ];
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
    };
  };
}
