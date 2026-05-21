# Linux desktop utilities — file managers, media players, etc.
{...}: {
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
        ffmpeg-headless
      ];
    };
    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.appimage-run];
      programs.appimage = {
        enable = true;
        binfmt = true;
      };
    };
  };
}
