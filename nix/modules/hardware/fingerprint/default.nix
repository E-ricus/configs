# Fingerprint authentication with parallel password support (pam-fprint-grosshack).
{ den, self, ... }: {
  # Package definition — colocated with the aspect that uses it
  perSystem = {pkgs, ...}: {
    packages.pam-fprint-grosshack = pkgs.callPackage ./_pam-fprint-grosshack.nix {};
  };

  den.aspects.fingerprint = {
    nixos = { pkgs, lib, config, ... }: let
      pam-fprint-grosshack = self.packages.${pkgs.stdenv.hostPlatform.system}.pam-fprint-grosshack;
      pam_fprintd_grosshack = "${pam-fprint-grosshack}/lib/security/pam_fprintd_grosshack.so";
      pamServices = ["sudo" "hyprlock" "swaylock" "gtklock" "noctalia"];
    in {
      services.fprintd.enable = true;

      security.pam.services = let
        mkGrosshackService = name: {
          ${name} = {
            fprintAuth = false;
            rules.auth.fprintd-grosshack = {
              order = config.security.pam.services.${name}.rules.auth.unix.order - 10;
              control = "sufficient";
              modulePath = pam_fprintd_grosshack;
            };
          };
        };
      in
        lib.mkMerge ([
            {greetd.fprintAuth = false;}
          ]
          ++ (map mkGrosshackService pamServices));
    };
  };

  # Fingerprint with Elan TOD driver (for specific hardware)
  den.aspects.fingerprint-elan = {
    includes = [den.aspects.fingerprint];
    nixos = { pkgs, ... }: {
      services.fprintd.tod = {
        enable = true;
        driver = pkgs.libfprint-2-tod1-elan;
      };
    };
  };
}
