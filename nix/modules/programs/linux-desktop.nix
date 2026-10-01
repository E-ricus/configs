# Linux desktop utilities — file managers, media players, etc.
{...}: {
  den.aspects.linux-desktop = {
    homeManager = {pkgs, ...}: let
      # Apps that self-register URL schemes (Claude Desktop, nelly-connector)
      # drop a .desktop into ~/.local/share/applications but never refresh that
      # directory's mimeinfo.cache. GIO builds its scheme->app map from that
      # cache, so until it is rebuilt g_app_info_get_all_for_type() returns
      # nothing and the xdg-desktop-portal "Open With" chooser shows
      # "No Apps Available" — even though xdg-mime query default resolves fine,
      # because [Default Applications] in mimeapps.list is read separately.
      # Nothing in home-manager or NixOS regenerates the *user* cache, so we do.
      refreshDesktopDatabase = pkgs.writeShellScript "refresh-desktop-database" ''
        set -eu
        dir="$HOME/.local/share/applications"
        cache="$dir/mimeinfo.cache"
        [ -d "$dir" ] || exit 0

        # Skip when the cache already post-dates every entry. Besides avoiding
        # pointless work, this is what stops the .path unit below from
        # re-triggering on the cache file we ourselves just wrote.
        if [ -e "$cache" ] && [ -z "$(
          ${pkgs.findutils}/bin/find "$dir" -maxdepth 1 -name '*.desktop' \
            -newer "$cache" -print -quit
        )" ]; then
          exit 0
        fi

        exec ${pkgs.desktop-file-utils}/bin/update-desktop-database "$dir"
      '';
    in {
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
        handy
        wtype
        localsend
        desktop-file-utils
      ];

      systemd.user.services.refresh-desktop-database = {
        Unit.Description = "Rebuild mimeinfo.cache in ~/.local/share/applications";
        Service = {
          Type = "oneshot";
          ExecStart = "${refreshDesktopDatabase}";
        };
        # Also run once per login, so a stale cache is corrected at session start.
        Install.WantedBy = ["default.target"];
      };

      systemd.user.paths.refresh-desktop-database = {
        Unit.Description = "Watch ~/.local/share/applications for new .desktop entries";
        Path.PathChanged = "%h/.local/share/applications";
        Install.WantedBy = ["default.target"];
      };
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
