# Linux desktop utilities — file managers, media players, etc.
{den, ...}: {
  den.aspects.linux-desktop = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        nautilus
        jmtpfs
        font-awesome
        btop
        vlc
        gcc
        gnumake
      ];
    };
  };
}
