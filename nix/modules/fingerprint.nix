# Fingerprint authentication module with parallel password support.
#
# Uses pam-fprint-grosshack to enable simultaneous fingerprint + password prompts.
# When enabled, the fingerprint reader activates in the background while the
# password prompt is displayed. Whichever method succeeds first wins:
# - Touch the fingerprint sensor -> authenticated
# - Type your password -> authenticated
#
# This solves the problem of being blocked by the fingerprint prompt when
# the sensor is unavailable (e.g., laptop lid closed with external monitor).
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.fingerprint-config;

  pam-fprint-grosshack = pkgs.callPackage ./pkgs/pam-fprint-grosshack.nix {};
  pam_fprintd_grosshack = "${pam-fprint-grosshack}/lib/security/pam_fprintd_grosshack.so";
in {
  options = {
    fingerprint-config = {
      enable = lib.mkEnableOption "fingerprint authentication with parallel password support";

      pamServices = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        # Note: greetd is excluded because its gnome-keyring integration adds
        # extra pam_unix (unix-early) before grosshack, causing multiple password
        default = ["sudo" "login" "hyprlock" "swaylock" "gtklock" "noctalia"];
        description = "PAM services to enable fingerprint authentication for.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable the fprintd daemon
    services.fprintd.enable = true;

    # Disable the default NixOS fprintd PAM integration (which is sequential)
    # and inject the grosshack module instead for true parallel auth.
    security.pam.services = let
      mkGrosshackService = name: {
        ${name} = {
          # Disable the default sequential fprintd PAM rule
          fprintAuth = false;

          # Insert grosshack before pam_unix for parallel auth.
          # The grosshack module starts the fingerprint reader in a background
          # thread and returns immediately, allowing pam_unix to prompt for
          # the password. Whichever succeeds first authenticates the user.
          rules.auth.fprintd-grosshack = {
            order = config.security.pam.services.${name}.rules.auth.unix.order - 10;
            control = "sufficient";
            modulePath = pam_fprintd_grosshack;
          };
        };
      };
    in
      lib.mkMerge ([
          # Disable fingerprint for greetd — its gnome-keyring integration adds
          # extra pam_unix (unix-early) before grosshack, causing multiple
          # password prompts. The greeter works fine with password-only.
          {greetd.fprintAuth = false;}
        ]
        ++ (map mkGrosshackService cfg.pamServices));
  };
}
