{
  description = "Flake for a Desktop environment with Home Manager enabled";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:

  let
    styleCss = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/fursman/NixOS/main/config/waybar-style.css";
      sha256 = "0wjwqfq8b8lk58vs34sxx3b81hbkv4y40fpr2z024m6wiy59fq3f";
    };
    weatherScript = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/fursman/NixOS/main/config/weather-script.py";
      sha256 = "0mig4i6fkhym4kyx1ns3xkill9dgvsfmjqqf373yfma2d2sqjlcq";
    };
    spotlightDarkRasi = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/fursman/NixOS/main/config/spotlight-dark.rasi";
      sha256 = "0ns89bqh8y23nwqij4da9wbas4x00l9mb66j769d8a5yy6hr4hzn";
    };
    desktopNix = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/fursman/NixOS/main/config/desktop.nix";
      sha256 = "04y7kpfqi2qpz4cs01cf30x7h8m1q0xlspd79k0nhfqiw787jmgj";
    };
  in
  {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hardware-configuration.nix
          desktopNix
          ({ config, pkgs, ... }: {
            environment.etc."wallpapers".source = pkgs.fetchFromGitHub {
              owner = "fursman";
              repo = "wallpaper";
              rev = "main";
              sha256 = "QDU4r+pJAOQknlNdZh18x9vh4/gj/itQ/GV4Zu0Tf9M=";
            };
            environment.etc."wallpapers".target = "wallpaper";
          })
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.user = { pkgs, ... }: {
              home.username = "user";
              home.homeDirectory = "/home/user";
              home.file.".local/share/rofi/themes/spotlight-dark.rasi".source = spotlightDarkRasi;
              home.file.".config/rofi/config.rasi".text = ''
                @theme "/home/user/.local/share/rofi/themes/spotlight-dark.rasi"
              '';
              home.file.".config/hypr/hyprpaper.conf".text = ''
                ipc = on
                preload = /etc/wallpaper/1.png
                preload = /etc/wallpaper/2.png
                preload = /etc/wallpaper/3.png
                preload = /etc/wallpaper/4.png
                preload = /etc/wallpaper/5.png
                preload = /etc/wallpaper/6.png
                preload = /etc/wallpaper/7.png
                preload = /etc/wallpaper/8.png
              '';

              programs.home-manager.enable = true;

              home.pointerCursor = {
                name = "Adwaita";
                package = pkgs.gnome.adwaita-icon-theme;
                size = 48;
                x11 = {
                  enable = true;
                  defaultCursor = "Adwaita";
                };
              };

              programs.kitty = {
                enable = true;
                settings = {
                  font_family = "JetBrains Mono Nerd Font";
                  bold_font = "auto";
                  italic_font = "auto";
                  bold_italic_font = "auto";
                  font_size = "12.0";
                  background_opacity = "0.5";
                  background_blur = "1";
                  remember_window_size = "no";
                  initial_window_width = "1080";
                  initial_window_height = "600";
                  window_margin_width = "15";
                  confirm_os_window_close = "0";
                  tab_bar_edge = "top";
                  tab_bar_style = "powerline";
                  tab_powerline_style = "angled";
                  cursor_shape = "beam";
                  cursor_blink_interval = "0";
                  disable_ligatures = "never";
                  mouse_hide_wait = "3.0";
                  url_style = "curly";
                  "map ctrl+shift+c" = "copy_to_clipboard";
                  "map cmd+c" = "copy_and_clear_or_interrupt";
                };
              };

              programs.waybar = {
                enable = true;
                settings = [{
                  "layer" = "top";
                  "position" = "top";
                  "height" = 30;
                  "modules-left" = ["hyprland/workspaces" "custom/weather" "custom/spaces" "wlr/taskbar"];
                  "modules-center" = ["hyprland/window"];
                  "modules-right" = ["network" "memory" "cpu" "temperature" "tray" "pulseaudio" "battery" "clock#date" "clock#time" ];
                  "hyprland/workspaces" = {
                    "on-click" = "activate";
                    "format" = "{icon}";
                    "format-icons" = {
                      "1" = " ";
                      "2" = " ";
                      "3" = " ";
                      "4" = " ";
                      "5" = " ";
                    };
                    "persistent-workspaces" = {
                      "1" = "[eDP-1],"; 
                      "2" = "[eDP-1],"; 
                      "3" = "[eDP-1],"; 
                      "4" = "[eDP-1],"; 
                      "5" = "[eDP-1],"; 
                    }; 
                  }; 
                  "custom/weather" = {
                    "exec" = "python ${weatherScript}";
                    "tooltip" = true;
                    "format" ="{}";
                    "interval" = 30;
                    "return-type" = "json";
                  };
                  "custom/spaces" = {
                      "format" = "  ";
                      "tooltip" = false;
                      "on-scroll-down" = "/usr/local/bin/hyprctl dispatch workspace m+1";
                      "on-scroll-up" = "/usr/local/bin/hyprctl dispatch workspace m-1";
                      "on-click" = "hyprctl hyprpaper wallpaper eDP-1,/etc/wallpaper/$((RANDOM%8+1)).png";
                  };
                  "wlr/taskbar" = {
                    "on-click" = "activate";
                    "on-click-middle" = "close";
                  };
                  "battery" = {
                    "interval" = 10;
                    "states" = {
                      "warning" = 30;
                      "critical" = 15;
                    };
                    "format" = "  {icon}  {capacity}%";
                    "format-discharging" = "{icon}  {capacity}%";
                    "format-icons" = ["" "" "" "" ""];   
                    "tooltip" = true;
                  };
                  "clock#time" = {
                    "interval" = 1;
                    "format" = "  {:%H:%M:%S}";
                    "tooltip" = false;
                  };
                  "clock#date" = {
                    "interval" = 10;
                    "format" = "  {:%e %b %Y}";
                    "tooltip-format" = "{:%e %B %Y}";
                  };
                  "cpu" = {
                    "interval" = 5;
                    "format" = "  {usage}%";
                    "states" = {
                      "warning" = 70;
                      "critical" = 90;
                    };
                  };
                  "memory" = {
                    "interval" = 5;
                    "format" = "  {}%";
                    "states" = {
                      "warning" = 70;
                      "critical" = 90;
                    };
                  };
                  "network" = {
                    "interval" = 5;
                    "format-wifi" = "  {essid} ({signalStrength}%)  {bandwidthUpBits}  {bandwidthDownBits}";
                    "format-ethernet" = "  {ifname}: {ipaddr}/{cidr}";
                    "format-disconnected" = "  Disconnected";
                    "tooltip-format" = "{ifname}: {ipaddr}";
                  };
                  "pulseaudio" = {
                    "scroll-step" = 1;
                    "format" = "{icon}  {volume}%";
                    "format-bluetooth" = "{icon}  {volume}%";
                    "format-muted" = "";
                    "format-icons" = {
                      "headphones" = "";
                      "handsfree" = "";
                      "headset" = "";
                      "phone" = "";
                      "portable" = "";
                      "car" = "";
                      "default" = ["" ""];
                    };
                  };
                  "temperature" = {
                    "hwmon-path-abs" = "/sys/devices/platform/coretemp.0/hwmon";
                    "input-filename" = "temp1_input";
                    "critical-threshold" = 80;
                    "interval" = 5;
                    "format" = "{icon}  {temperatureC}°C";
                    "format-icons" = ["" "" "" "" ""];
                  };
                }];
                style = "${styleCss}";
              };

              wayland.windowManager.hyprland.enable = true;
              wayland.windowManager.hyprland.extraConfig = ''

###########################################################################
 _   _                  _                 _    ____             __ _       
| | | |_   _ _ __  _ __| | __ _ _ __   __| |  / ___|___  _ __  / _(_) __ _ 
| |_| | | | | '_ \| '__| |/ _` | '_ \ / _` | | |   / _ \| '_ \| |_| |/ _` |
|  _  | |_| | |_) | |  | | (_| | | | | (_| | | |__| (_) | | | |  _| | (_| |
|_| |_|\__, | .__/|_|  |_|\__,_|_| |_|\__,_|  \____\___/|_| |_|_| |_|\__, |
       |___/|_|                                                      |___/ 

###########################################################################

# See https://wiki.hyprland.org/Configuring/Monitors/
monitor=eDP-1,highres@highrr,0x0,1.0
monitor=HDMI-A-1,highres@highrr,auto,1.0

# See https://wiki.hyprland.org/Configuring/Keywords/ for more

# Execute your favorite apps at launch
exec-once = waybar
exec-once = hyprpaper
exec-once = sleep 9 ; hyprctl hyprpaper wallpaper eDP-1,/etc/wallpaper/$((RANDOM%8+1)).png
exec-once = sleep 10 ; hyprctl keyword misc:disable_hyprland_logo true

# Some default env vars.
env = XCURSOR_SIZE,48

# For all categories, see https://wiki.hyprland.org/Configuring/Variables/
input {
    kb_layout = us
    kb_variant =
    kb_model =
    kb_options =
    kb_rules =

    # Enable Keyboard Special Keys

    # Sink volume raise optionally with --device
    binde = ,XF86AudioRaiseVolume, exec, swayosd --output-volume raise
    # Sink volume lower optionally with --device
    binde = ,XF86AudioLowerVolume, exec,  swayosd --output-volume lower
    # Sink volume toggle mute
    bindr = ,XF86AudioMute, exec, swayosd --output-volume mute-toggle
    # Source volume toggle mute
    bindr = ,XF86AudioMicMute, exec, swayosd --input-volume mute-toggle

    # Brightness raise
    binde = ,XF86MonBrightnessUp, exec, brightnessctl s +5
    # Brightness lower
    binde = ,XF86MonBrightnessDown, exec, brightnessctl s 5-

    follow_mouse = 1

    touchpad {
        natural_scroll = yes
    }

    sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
}

general {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more

    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(0000FFee) 45deg
    col.inactive_border = rgba(595959aa)

    layout = dwindle
}

misc {
    disable_hyprland_logo = false
    disable_splash_rendering = true
}

decoration {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more
    blur {
        enabled = true
        size = 10
        passes = 2
        new_optimizations = on
    }
    drop_shadow = yes
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
    rounding = 5
}

animations {
    enabled = yes

    # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

    bezier = myBezier, 0.05, 0.9, 0.1, 1.05

    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

dwindle {
    # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
    pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
    preserve_split = yes # you probably want this
}

master {
    # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
    new_is_master = true
}

gestures {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more
    workspace_swipe = on
}

# Example per-device config
# See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
device:epic-mouse-v1 {
    sensitivity = -0.5
}

# Example windowrule v1
# windowrule = float, ^(kitty)$
# Example windowrule v2
# windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
# See https://wiki.hyprland.org/Configuring/Window-Rules/ for more

# See https://wiki.hyprland.org/Configuring/Keywords/ for more
$mainMod = SUPER

# Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
bind = $mainMod, RETURN, exec, rofi -show run
bind = $mainMod, T, exec, kitty
bind = $mainMod, Q, killactive, 
bind = $mainMod, X, exec, wlogout --protocol layer-shell
bind = $mainMod, B, exec, firefox
bind = $mainMod, F, exec, thunar
bind = $mainMod, P, exec, podman-desktop --enable-features=UseOzonePlatform --ozone-platform=wayland
bind = $mainMod, C, exec, code --password-store="gnome" --use-gl=desktop
bind = $mainMod, L, exec, swaylock --screenshots --clock --indicator --indicator-radius 200 --indicator-thickness 40 --effect-blur 8x8 --effect-vignette 0.8:0.8 --text-color ffffff --ring-color 44006666 --key-hl-color 00000000 --line-color 00000000 --inside-color 00000000 --separator-color 00000000 --grace 0 --fade-in 0.5 -F
bind = $mainMod, V, exec, virt-manager
bind = $mainMod, P, pseudo, # dwindle
bind = $mainMod, J, togglesplit, # dwindle

# Move focus with mainMod + arrow keys
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Switch workspaces with mainMod + [0-9]
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move active window to a workspace with mainMod + SHIFT + [0-9]
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Scroll through existing workspaces with mainMod + scroll
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Move/resize windows with mainMod + LMB/RMB and dragging
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

'';

            gtk = {
              enable = true;

              iconTheme = {
                name = "Dracula";
                package = pkgs.dracula-icon-theme;
              };

              theme = {
                name = "Dracula";
                package = pkgs.dracula-theme;
              };

              cursorTheme = {
                name = "vanilla";
                package = pkgs.vanilla-dmz;
                size = 30;
              };

              gtk3.extraConfig = {
                Settings = ''
                  gtk-application-prefer-dark-theme=1
                '';
              };

              gtk4.extraConfig = {
                Settings = ''
                  gtk-application-prefer-dark-theme=1
                '';
                };
              };

              home.sessionVariables.GTK_THEME = "Dracula";

              programs.firefox.enable = true;

              home.packages = with pkgs; [
                (python3.withPackages (ps: with ps; [ requests ]))                  
                gimp
                signal-desktop
                steam           
                xfce.thunar
                gnome.eog
                links2
                wget
                vlc
                rofi-wayland
                swayosd
                brightnessctl
                hyprpaper
                swaylock-effects
                wlogout
                vscode.fhs
                gnome.seahorse
                imagemagick
              ];
                
              home.stateVersion = "23.11";

            };
          }
        ];  
      };        
    };
  }; 
}
