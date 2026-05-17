# Aseprite — pixel art editor with XWayland scaling defaults.
# Aseprite has no native Wayland backend (only X11 via laf), so it runs
# through xwayland-satellite. This aspect seeds ~/.config/aseprite/aseprite.ini
# with correct screen/UI scale on first install so it's usable out of the box.
{den, ...}: {
  den.aspects.aseprite = {
    includes = [
      ({host, ...}: {
        homeManager = {
          pkgs,
          lib,
          ...
        }: let
          # Aseprite uses integer screen/UI scale (1, 2, 3…).
          # Ceil the host display scale so e.g. 1.75 -> 2.
          # TODO: fix cursor that is gigantic
          aseScale = let
            floored = builtins.floor host.display.scale;
          in
            if floored < host.display.scale
            then floored + 1
            else floored;
        in {
          home.packages = [pkgs.aseprite];

          # Seed aseprite preferences on first install so the UI
          # is correctly scaled without manual configuration.
          home.activation.aseprite-config = lib.hm.dag.entryAfter ["writeBoundary"] ''
                        configFile="$HOME/.config/aseprite/aseprite.ini"
                        if [ ! -f "$configFile" ]; then
                          mkdir -p "$(dirname "$configFile")"
                          cat > "$configFile" << 'EOF'
            [general]
            screen_scale = ${toString aseScale}
            ui_scale = ${toString aseScale}
            EOF
                        fi
          '';
        };
      })
    ];
  };
}
