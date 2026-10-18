{ config, lib, pkgs, ... }:

let
  mod = config.wayland.windowManager.sway.config.modifier;

  # Ayu Mirage palette shared by sway, waybar and alacritty
  ayu = {
    border = "#ffcc66";
    borderInactive = "#191e2add";
    foreground = "#6c7680";
    foregroundInactive = "#bfbab0";
    urgent = "#ff3333";
  };
in
{
  # Sway itself is installed by the NixOS module (programs.sway in
  # modules/desktop-environment.nix); home-manager only owns the config.
  wayland.windowManager.sway = {
    enable = true;
    package = null;
    checkConfig = false; # requires a non-null package

    config = {
      modifier = "Mod4";
      left = "h";
      down = "j";
      up = "k";
      right = "l";
      terminal = "alacritty";
      # pass the final command to swaymsg so the window opens on the
      # workspace the command was run on
      menu = "wofi --show run | xargs swaymsg exec --";

      # all bindsyms get --to-code so they work on the cz layout too
      bindkeysToCode = true;
      keybindings = lib.mkOptionDefault {
        # LinkedIn
        "${mod}+Shift+Ctrl+Alt+l" = "exec firefox linkedin.com";

        "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
      };

      input."type:keyboard" = {
        xkb_layout = "us,cz";
        xkb_variant = ",qwerty";
        xkb_options = "grp:win_space_toggle";
      };

      output."*".bg = "${./wallpaper-ntt.jpg} fill";

      colors = {
        focused = {
          border = ayu.border;
          background = ayu.borderInactive;
          text = ayu.border;
          indicator = ayu.borderInactive;
          childBorder = ayu.borderInactive;
        };
        focusedInactive = {
          border = ayu.borderInactive;
          background = ayu.borderInactive;
          text = ayu.foregroundInactive;
          indicator = ayu.borderInactive;
          childBorder = ayu.borderInactive;
        };
        unfocused = {
          border = ayu.borderInactive;
          background = ayu.borderInactive;
          text = ayu.foregroundInactive;
          indicator = ayu.borderInactive;
          childBorder = ayu.borderInactive;
        };
      };

      # waybar is launched via swaybar_command below, not the HM bar module
      bars = [ ];

      startup = [
        # scripts from modules/desktop-environment.nix
        { command = "dbus-sway-environment"; }
        { command = "configure-gtk"; }
      ];
    };

    extraConfig = ''
      bar {
        swaybar_command waybar
      }
    '';
  };

  programs.waybar = {
    enable = true;
    settings.mainBar = {
      name = "ayu-mirage"; # Options: ayu, ayu-mirage, ayu-dark
      layer = "top";
      position = "top";
      height = 30;
      width = 1920;
      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "clock" ];
      modules-right = [ "tray" "memory" "cpu" "pulseaudio" ];

      "custom/separator" = {
        format = "·";
        tooltip = false;
      };
      "sway/mode" = {
        format = "<span style=\"italic\">{}</span>";
      };
      "sway/workspaces" = {
        disable-scroll-wraparound = true;
        enable-bar-scroll = true;
      };
      tray = {
        icon-size = 14;
        spacing = 22;
      };
      clock = {
        format = "{:%H:%M}";
        format-alt = "{:%A, %B %d}";
        tooltip = false;
      };
      "custom/system" = {
        format = "";
        on-click = "swaynag -t ayu-mirage -m '' -b 'Exit' 'swaymsg exit' -b 'Reload' 'swaymsg reload' -b 'Reboot' 'swaymsg exec systemctl reboot' -b 'Shut down' 'systemctl poweroff'";
        on-click-right = "swaymsg mode System";
      };
      "custom/files" = {
        format = "";
        tooltip = false;
        on-click = "nemo";
      };
      "custom/terminal" = {
        format = "";
        tooltip = false;
        on-click = "swaymsg scratchpad show";
      };
      disk = {
        interval = 30;
        format = "  {percentage_used}%";
        path = "/";
        tooltip = true;
        tooltip-format = "{used} / {total}";
      };
      "custom/wttr" = {
        exec = "curl wttr.in/Prague,Czechia?format=\"%c+%t\"";
        interval = 1800;
        tooltip = false;
      };
      idle_inhibitor = {
        format = "{icon}";
        tooltip = false;
        format-icons = {
          activated = "";
          deactivated = "";
        };
      };
      pulseaudio = {
        format = "{icon}  {volume}%";
        format-bluetooth = "{icon} ";
        format-muted = "";
        format-icons = {
          headphones = "";
          handsfree = "";
          headset = "";
          phone = "";
          portable = "";
          car = "";
          default = [ "" "" ];
        };
        scroll-step = 5;
        on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
        on-click-middle = "pavucontrol";
        tooltip = false;
      };
      temperature = {
        thermal-zone = 2;
        hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
        critical-threshold = 80;
        format-critical = "{temperatureC}°C ";
        format = " {temperatureC}°C";
      };
      cpu = {
        tooltip = false;
        format = "  {}%";
      };
      network = {
        format = "{icon}  {ifname}";
        format-wifi = "{icon}  {essid}";
        format-ethernet = "{icon}  {ifname}";
        format-disconnected = "Offline";
        format-icons = {
          wifi = [ "" ];
          ethernet = [ "" ];
          disconnected = [ "" ];
        };
        tooltip = true;
        tooltip-format = "IP: {ipaddr}\nRate: {bandwidthUpBits} / {bandwidthDownBits}";
      };
      memory = {
        interval = 30;
        format = "☰  {avail:0.1f}GB";
        tooltip = true;
        tooltip-format = "{used:0.1f}GB / {total:0.1f}GB";
      };
    };

    # Ayu style for Waybar
    style = ''
      * {
        font-weight: 700;
        font-family: 'Iosevka Nerd Font', sans-serif;
        font-size: 13px;
      }

      #waybar {
        background: transparent;
        color: ${ayu.foreground};
        transition: background-color 0.2s;
      }

      #waybar.ayu-mirage {
        color: ${ayu.foregroundInactive};
      }

      #waybar.ayu-dark {
        color: #b3b1ad;
      }

      #workspaces {
        margin: 0 3px 0 1px;
      }

      #workspaces button {
        background: transparent;
        border: none;
        padding: 0 8px;
      }

      #workspaces button.focused {
        color: #ff9940;
      }

      #waybar.ayu-mirage #workspaces button.focused {
        color: ${ayu.border};
      }

      #waybar.ayu-dark #workspaces button.focused {
        color: #e6b450;
      }

      #workspaces button.urgent {
        color: #f51818;
      }

      #waybar.ayu-mirage #workspaces button.urgent {
        color: ${ayu.urgent};
      }

      #waybar.ayu-dark #workspaces button.urgent {
        color: ${ayu.urgent};
      }

      #battery,
      #cpu,
      #memory,
      #disk,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #custom-media,
      #tray,
      #idle_inhibitor,
      #custom-terminal,
      #custom-files,
      #custom-wttr,
      #custom-system,
      #custom-separator,
      #mode {
        padding: 0 12px;
      }

      #idle_inhibitor {
        padding: 0 18px;
      }

      #tray {
        opacity: 0.8;
        padding: 8px;
      }

      #custom-system {
        margin-right: 6px;
      }
    '';
  };

  programs.alacritty = {
    enable = true;
    theme = "ayu_mirage";
  };

  programs.wofi.enable = true;
}
