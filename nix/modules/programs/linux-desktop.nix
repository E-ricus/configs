# Linux desktop utilities — file managers, media players, etc.
{...}: {
  den.aspects.linux-desktop = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        nautilus
        android-file-transfer
        gvfs
        font-awesome
        btop
        vlc
        gcc
        gnumake
        cmake
        ffmpeg-headless
        gimp
        unzip
        doxx
        xleak
        dragon-drop
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
