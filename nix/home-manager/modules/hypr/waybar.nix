{
  config,
  pkgs,
  ...
}:
# Heavily inspared by omarchy: https://github.com/basecamp/omarchy/blob/master/config/waybar/config.jsonc
{
  services.blueman-applet.enable = true;

  programs.waybar = {
    enable = true;
    settings = {
      mainbar = {
        layer = "top";
        position = "top";
        height = 30;

        modules-left = ["hyprland/workspaces" "hyprland/window"];
        modules-center = ["clock"];
        modules-right = ["group/tray-expander" "pulseaudio" "network" "battery" "cpu"];

        "group/tray-expander" = {
          orientation = "inherit";
          drawer = {
            transition-duration = 600;
            children-class = "tray-group-item";
          };
          modules = ["custom/expand-icon" "tray"];
        };
        "custom/expand-icon" = {
          format = "";
          tooltip = false;
        };
        "tray" = {
          icon-size = 14;
          spacing = 17;
        };

        "hyperland/workspaces" = {
          format = "{id}";
        };

        "clock" = {
          format = "{:L%A %H:%M}";
          format-alt = "{:L%d %B W%V %Y}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };

        "cpu" = {
          interval = 5;
          format = "󰍛";
          on-click = "alacritty -e btop";
        };

        "battery" = {
          format = "{capacity}% {icon}";
          format-charging = "{icon}";
          format-discharging = "{icon}";
          format-plugged = "";
          format-full = "󰂅";
          format-icons = {
            charging = ["󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅"];
            default = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
          };
          interval = 5;
          tooltip-format-discharging = "{power:>1.0f}W↓ {capacity}%";
          tooltip-format-charging = "{power:>1.0f}W↑ {capacity}%";
          states = {
            warning = 20;
            critical = 10;
          };
        };

        "network" = {
          format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
          format = "{icon}";
          format-wifi = "{icon}";
          format-ethernet = "󰀂";
          format-disconnected = "󰤮";
          tooltip-format-wifi = "{essid} ({frequency} GHz)\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
          tooltip-format-ethernet = "⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
          tooltip-format-disconnected = "Disconected";
          interval = 3;
          spacing = 1;
          on-click = "nm-connection-editor";
        };

        "pulseaudio" = {
          format = "{icon}";
          scroll-step = 5;
          tooltip-format = "Playing at {volume}%";
          format-muted = "";
          format-icons = {
            default = ["" "" ""];
          };
        };
      };
    };
    style = builtins.readFile ../../config/hypr/waybar-style.css;
  };
}
