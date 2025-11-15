{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    mac-packages.enable =
      lib.mkEnableOption "enables macOS-specific packages and configuration";
  };

  config = lib.mkIf config.mac-packages.enable {
    # macOS-specific packages
    home.packages = with pkgs; [
      # Media and graphics
      ffmpeg
      imagemagick
      poppler
      resvg

      # Compression
      p7zip

      # Development libraries (needed for building native extensions)
      pkg-config
      cairo
      pango
      libpng
      libjpeg
      giflib
      librsvg

      # Database tools
      postgresql

      # Containers
      podman
      docker-compose

      # CLI tools
      ngrok

      # Build tools
      cmake
    ];
  };
}
