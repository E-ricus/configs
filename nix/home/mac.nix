{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./common.nix
  ];

  home = {
    username = "ericpuentes";
    homeDirectory = "/Users/ericpuentes";
    stateVersion = "25.05";

    # macOS-specific packages
    packages = with pkgs; [
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

      # DevOps
      docker-compose
      podman-compose

      # CLI tools
      ngrok

      # Build tools
      cmake

      # Shell
      bash-completion
    ];
  };

  programs.home-manager.enable = true;
}
