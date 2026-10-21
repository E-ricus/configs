# dragon-drop integration for captures.
#
{self, ...}: {
  # ── Scripts exposed as packages (referenced by wrapper.nix + the service) ──
  perSystem = {pkgs, ...}: let
    inherit (pkgs) lib;

    dragonExe = lib.getExe pkgs.dragon-drop;
    niriExe = lib.getExe pkgs.niri;
    jqExe = lib.getExe pkgs.jq;
    inotifyExe = "${pkgs.inotify-tools}/bin/inotifywait";
  in {
    packages = {
      # Watches the capture directories; launches dragon-drop for each new file.
      dragon-capture-watch = pkgs.writeShellApplication {
        name = "dragon-capture-watch";
        runtimeInputs = [pkgs.inotify-tools pkgs.dragon-drop pkgs.coreutils];
        text = ''
          # Directories to watch. Missing ones are created so inotify can attach.
          screenshot_dir="''${SCREENSHOT_DIR:-$HOME/Pictures/Screenshots}"
          recording_dir="''${RECORDING_DIR:-$HOME/Videos/Recordings}"
          mkdir -p "$screenshot_dir" "$recording_dir"

          launch_dragon() {
            file="$1"
            # Ignore partials / hidden temp files written by the capture tools.
            base="$(basename "$file")"
            case "$base" in
              .*|*.tmp|*.part|*.crdownload) return 0 ;;
            esac
            # Recordings finalize slightly after the event fires; wait for a
            # non-empty, size-stable file before handing it to dragon-drop.
            for _ in 1 2 3 4 5 6 7 8 9 10; do
              [ -s "$file" ] || { sleep 0.3; continue; }
              size1=$(stat -c %s "$file" 2>/dev/null || echo 0)
              sleep 0.3
              size2=$(stat -c %s "$file" 2>/dev/null || echo 0)
              [ "$size1" = "$size2" ] && break
            done
            [ -s "$file" ] || return 0
            # New window per capture; exit after the drop; keep it on top.
            ${dragonExe} --and-exit --on-top "$file" &
          }

          # -m: monitor continuously. close_write catches locally written files;
          # moved_to catches atomic renames (tool writes tmp then renames).
          ${inotifyExe} -m -q \
            -e close_write -e moved_to \
            --format '%w%f' \
            "$screenshot_dir" "$recording_dir" \
          | while IFS= read -r path; do
              case "$path" in
                *.png|*.jpg|*.jpeg|*.mp4|*.mkv|*.webm|*.gif) launch_dragon "$path" ;;
              esac
            done
        '';
      };

      # Moves an existing dragon-drop window to the focused workspace without
      # stealing focus. No-op (silent) when no dragon-drop window exists.
      dragon-summon = pkgs.writeShellApplication {
        name = "dragon-summon";
        runtimeInputs = [pkgs.niri pkgs.jq pkgs.coreutils];
        text = ''
          # Most-recently-opened dragon-drop window (highest id), if any.
          win_id="$(${niriExe} msg -j windows \
            | ${jqExe} -r '[.[] | select(.app_id == "dragon-drop")] | sort_by(.id) | last | .id // empty')"
          [ -n "$win_id" ] || exit 0

          # Focused workspace index.
          ws_idx="$(${niriExe} msg -j workspaces \
            | ${jqExe} -r '.[] | select(.is_focused == true) | .idx')"
          [ -n "$ws_idx" ] || exit 0

          ${niriExe} msg action move-window-to-workspace \
            --window-id "$win_id" --focus false "$ws_idx"
        '';
      };
    };
  };

  # ── Aspect: user service that runs the watcher for the graphical session ──
  flake.modules.homeManager.dragon-capture = {pkgs, ...}: let
    watch = self.packages.${pkgs.stdenv.hostPlatform.system}.dragon-capture-watch;
  in {
    systemd.user.services.dragon-capture-watch = {
      Unit = {
        Description = "Launch dragon-drop for new screenshots/recordings";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        Type = "simple";
        ExecStart = "${watch}/bin/dragon-capture-watch";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
