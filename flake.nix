{
  description = "Flake for a graphical environment with Home Manager enabled and NVIDIA GPU support";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    assistant.url = "github:fursman/Assistant";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, assistant, ... }: let

    theme = "Donuts"; # Define the theme variable here
    inherit (nixpkgs) lib;

    styleCss = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/fursman/NixOS/main/config/waybar-style.css";
      sha256 = "0nqlpdbwpzswn96kl0z98rb37p2jc8cz5d1ilxcr18icxzrizbxi";
    };
    weatherScript = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/fursman/NixOS/main/config/weather-script.py";
      sha256 = "0mig4i6fkhym4kyx1ns3xkill9dgvsfmjqqf373yfma2d2sqjlcq";
    };
    spotlightDarkRasi = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/fursman/NixOS/main/config/spotlight-dark.rasi";
      sha256 = "0ns89bqh8y23nwqij4da9wbas4x00l9mb66j769d8a5yy6hr4hzn";
    };
    server3080Nix = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/fursman/NixOS/main/config/server3080.nix";
      sha256 = "08byx63vkkpac3nns52dfnxd0wwaxkc0xfxnis4mg07h721yaswn";
    };
    serverTitanVNix = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/fursman/NixOS/main/config/serverTitanV.nix";
      sha256 = "1xzw8r2n003ayy5kdjkawa13zfamfqn0rmiikzysx86pycb6jv0x";
    };
    server4090Nix = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/fursman/NixOS/main/config/server4090.nix";
      sha256 = "02da1qfw2jz3ligfsl3w0v9208x4jqyl9vwzxf0jc4f6n2979zx8";
    };
    MacBookProNix = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/fursman/NixOS/main/config/MacBookPro.nix";
      sha256 = "1z9dcgiissn0zj2q73r4572sc1khv279ly1i0729d186yhzf6lyy";
    };
    MacMiniNix = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/fursman/NixOS/main/config/MacMini.nix";
      sha256 = "07fyvbr5hdss1ghlrf3jkid6srr9d6wqmapd5ii6gxgsq5y0klri";
    };
    Pi3Nix = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/fursman/NixOS/main/config/pi3.nix";
      sha256 = "1plny5f5k0spfl2ayw7c9gxf8c2lvhsxllzp3psj1p9fxg1kmm8f";
    };
    Pi4Nix = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/fursman/NixOS/main/config/pi4.nix";
      sha256 = "1x5fpc1vf7ygajpw1f87lahxv66rdmiid0hdbs2rkpclfqappg74";
    };
    sharedConfiguration = ({ config, pkgs, ... }: {
      imports = [
        home-manager.nixosModules.home-manager
      ];
    
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      home-manager.users.user = { pkgs, ... }: {

        home.username = "user";
        home.homeDirectory = "/home/user";

        # Home Manager specific configurations
        home.file.".local/share/rofi/themes/spotlight-dark.rasi".source = spotlightDarkRasi;
        home.file.".config/rofi/config.rasi".text = ''
          @theme "/home/user/.local/share/rofi/themes/spotlight-dark.rasi"
        '';

        home.file.".config/hypr/hyprpaper.conf".text = ''
          ipc = on
          ${lib.concatStringsSep "\n" (builtins.map (i: "preload = /etc/assets/Wallpaper/${theme}/${toString i}.jpg") (lib.range 1 8))}
        '';

        home.file.".config/hypr/wallpaper.sh".text = ''
          #!/usr/bin/env bash
          theme="${theme}" # Use the theme variable
          for monitor in $(hyprctl monitors | grep 'Monitor' | awk '{ print $2 }'); do
          hyprctl hyprpaper wallpaper "$monitor,/etc/assets/Wallpaper/$theme/$((RANDOM%8+1)).jpg"
          done
        '';

        home.file.".config/hypr/wallpaper.sh".executable = true;

        programs.home-manager.enable = true;

        home.pointerCursor = {
          name = "Adwaita";
          package = pkgs.adwaita-icon-theme;
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

        programs.wlogout = {
          enable = true;
          layout = [
          {
              "label" = "lock";
              "action" = "sleep 1 && swaylock --screenshots --clock --indicator --indicator-radius 200 --indicator-thickness 40 --effect-blur 8x8 --effect-vignette 0.8:0.8 --text-color ffffff --ring-color 44006666 --key-hl-color 00000000 --line-color 00000000 --inside-color 00000000 --separator-color 00000000 --grace 0 --fade-in 0.5 -F";
              "text" = "Lock";
              "keybind" = "l";
          }
          {
              "label" = "hibernate";
              "action" = "systemctl hibernate";
              "text" = "Hibernate";
              "keybind" = "h";
          }
          {
              "label" = "logout";
              "action" = "loginctl terminate-user $USER";
              "text" = "Logout";
              "keybind" = "e";
          }
          {
              "label" = "shutdown";
              "action" = "systemctl poweroff";
              "text" = "Shutdown";
              "keybind" = "s";
          }
          {
              "label" = "suspend";
              "action" = "systemctl suspend";
              "text" = "Suspend";
              "keybind" = "u";
          }
          {
              "label" = "reboot";
              "action" = "systemctl reboot";
              "text" = "Reboot";
              "keybind" = "r";
          }];
          style = ''
		* {
			background-image: none;
		}
		window {
			background-color: rgba(12, 12, 12, 0.9);
		}
		button {
		   color: #FFFFFF;
			background-color: #1E1E30;
			border-style: solid;
			border-width: 5px;
		       margin: 10px;
			background-repeat: no-repeat;
			background-position: center;
			background-size: 45%;
		}
		
		button:focus, button:active, button:hover {
			background-color: #000000;
			border-width: 5px;
			border-color: #47AFC4;
			outline-style: none;
		}
		
		#lock {
		   background-image: image(url("/etc/assets/wlogout/1.png"));
		}
		
		#logout {
		   background-image: image(url("/etc/assets/wlogout/2.png"));
		}
		
		#suspend {
		   background-image: image(url("/etc/assets/wlogout/3.png"));
		}
		
		#hibernate {
		   background-image: image(url("/etc/assets/wlogout/4.png"));
		}
		
		#shutdown {
		   background-image: image(url("/etc/assets/wlogout/5.png"));
		}
		
		#reboot {
		   background-image: image(url("/etc/assets/wlogout/6.png"));
		}
          '';
        };

        programs.waybar = {
          enable = true;
          settings = [{
            "layer" = "top";
            "position" = "top";
            "height" = 30;
            "modules-left" = ["hyprland/workspaces" "custom/weather" "custom/spaces" "wlr/taskbar"];
            "modules-center" = ["hyprland/window"];
            "modules-right" = [ "tray" "network" "bluetooth" "disk" "memory" "cpu" "temperature" "pulseaudio" "backlight" "battery" "clock#date" "clock#time" ];
            "hyprland/workspaces" = {
              "on-click" = "activate";
              "format" = "{icon}";
              "format-icons" = {
                "1" = " ";
                "2" = " ";
                "3" = " ";
                "4" = " ";
                "5" = " ";
                "6" = " ";
                "7" = " ";
                "8" = " ";
                "9" = "☂ ";
                "10" = "⚑ ";
              };
              "persistent-workspaces" = {
                "1" = "[eDP-1],"; 
                "2" = "[eDP-1],"; 
                "3" = "[eDP-1],"; 
                "4" = "[eDP-1],"; 
                "5" = "[eDP-1],"; 
                "6" = "[eDP-1],"; 
                "7" = "[eDP-1],"; 
                "8" = "[eDP-1],"; 
                "9" = "[eDP-1],"; 
                "10" = "[eDP-1],"; 
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
              "on-click" = "/home/user/.config/hypr/wallpaper.sh";
            };
            "bluetooth" = {
            	"format" = " {status}";
            	"format-connected" = " {device_alias}";
            	"format-connected-battery" = " {device_alias} {device_battery_percentage}%";
            	"tooltip-format" = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
            	"tooltip-format-connected" = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
            	"tooltip-format-enumerate-connected" = "{device_alias}\t{device_address}";
            	"tooltip-format-enumerate-connected-battery" = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
                "on-click" = "kitty blueman-manager";
            };
            "disk" = {
              "interval" = 30;
              "format" = " {path} {percentage_used}%";
              "path" = "/";
            };
            "wlr/taskbar" = {
              "on-click" = "activate";
              "on-click-middle" = "close";
            };
            "backlight" = {
              "device" = "acpi_video1";
              "format" = "{icon} {percent}%";
              "format-icons" = [ "" ];
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
              "format-ethernet" = "  {ifname}: {ipaddr}/{cidr}  {bandwidthUpBits}  {bandwidthDownBits}";
              "format-disconnected" = "  Disconnected";
              "tooltip-format" = "{ifname}: {ipaddr}";
              "on-click" = "kitty nmtui";
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

        # See https://wiki.hyprland.org/Configuring/Monitors/
        monitor=,highres@highrr,0x0,1.0
        monitor=,highres@highrr,auto,1.0
        
        # See https://wiki.hyprland.org/Configuring/Keywords/ for more
        
        # Execute your favorite apps at launch
        exec-once = waybar
        exec-once = hyprpaper
        exec-once = swayosd-server
        exec-once = sleep 3 ; /home/user/.config/hypr/wallpaper.sh
        exec-once = sleep 4 ; hyprctl keyword misc:disable_hyprland_logo true
        
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
       
            # ── AUDIO ─────────────────────────────
            # sink volume: raise / lower / mute
            bind  =  ,XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise
            bind  =  ,XF86AudioLowerVolume, exec, swayosd-client --output-volume lower
            bind  =  ,XF86AudioMute,        exec, swayosd-client --output-volume mute-toggle
            bind  =  ,XF86AudioMicMute,     exec, swayosd-client --input-volume  mute-toggle
            
            # OPTIONAL variants – pick ONE from each pair ↓↓↓
            # custom step (+15 / −15)
            #bind = ,XF86AudioRaiseVolume, exec, swayosd-client --output-volume  15
            #bind = ,XF86AudioLowerVolume, exec, swayosd-client --output-volume -15
            #
            # with max‑volume limit (120 %)
            #bind = ,XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise --max-volume 120
            #bind = ,XF86AudioLowerVolume, exec, swayosd-client --output-volume lower --max-volume 120
            #
            # per‑device custom step (+10 / −10)
            #bind = ,XF86AudioRaiseVolume, exec, swayosd-client --output-volume +10 --device alsa_output.pci-0000_11_00.4.analog-stereo.monitor
            #bind = ,XF86AudioLowerVolume, exec, swayosd-client --output-volume -10 --device alsa_output.pci-0000_11_00.4.analog-stereo.monitor
            
            # ── CAPS‑LOCK OSD ─────────────────────
            # plain OSD (trigger on key‑release)
            bindl = ,Caps_Lock, exec, swayosd-client --caps-lock
            # LED‑specific OSD (uncomment if you want it)
            #bindl = ,Caps_Lock, exec, swayosd-client --caps-lock-led input19::capslock
            
            # ── BRIGHTNESS ────────────────────────
            bind  = ,XF86MonBrightnessUp,   exec, swayosd-client --brightness raise
            bind  = ,XF86MonBrightnessDown, exec, swayosd-client --brightness lower
            # custom step (+10 / −10)
            #bind = ,XF86MonBrightnessUp,   exec, swayosd-client --brightness +10
            #bind = ,XF86MonBrightnessDown, exec, swayosd-client --brightness -10


            follow_mouse = 1
        
            touchpad {
                natural_scroll = yes
            }
        
            sensitivity = 0.5 # -1.0 - 1.0, 0 means no modification.
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
            shadow {
		            enabled = yes
                range = 4
                render_power = 3
                color = rgba(1a1a1aee)
            }
            rounding = 5
            active_opacity = 1
            inactive_opacity = 0.9
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
            new_status = slave
        }
        
        gestures {
            # See https://wiki.hyprland.org/Configuring/Variables/ for more
            workspace_swipe = on
        }
        
        # Example per-device config
        # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
        # device:epic-mouse-v1 {
        #    sensitivity = -0.5
        # }
        
        # Example windowrule v1
        # windowrule = float, ^(kitty)$
        # Example windowrule v2
        # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
        # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
        
        # See https://wiki.hyprland.org/Configuring/Keywords/ for more
        $mainMod = SUPER
        
        # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
        bind = $mainMod, SUPER_L, exec, nohup assistant >/dev/null 2>&1 &
        bind = $mainMod, RETURN, exec, rofi -show run
        bind = $mainMod, T, exec, kitty
        bind = $mainMod, G, exec, steam --tenfoot
        bind = $mainMod, Q, killactive, 
        bind = $mainMod, X, exec, wlogout --protocol layer-shell
        bind = $mainMod, B, exec, firefox
        bind = $mainMod ALT, B, exec, chromium
        bind = $mainMod, F, exec, thunar
        bind = $mainMod, K, exec, seahorse
        bind = $mainMod, S, exec, signal-desktop
        bind = $mainMod, Z, exec, zoom-us
        bind = $mainMod, R, exec, pika-backup
        bind = $mainMod, A, exec, pavucontrol
        bind = $mainMod, D, exec, podman-desktop
        bind = $mainMod, C, exec, code --password-store="gnome"
        bind = $mainMod, L, exec, swaylock --screenshots --effect-blur 8x8 --effect-vignette 0.8:0.8 --text-color ffffff --grace 0 --fade-in 0.5 -F
        # bind = $mainMod, L, exec, swaylock -f --screenshots --clock --indicator --indicator-radius 200 --indicator-thickness 40 --effect-blur 8x8 --effect-vignette 0.8:0.8 --text-color ffffff --ring-color 44006666 --key-hl-color 00000000 --line-color 00000000 --inside-color 00000000 --separator-color 00000000 --grace 0 --fade-in 0.5 -F
        bind = $mainMod, V, exec, virt-manager
        bind = $mainMod, P, pseudo, # dwindle
        bind = $mainMod, J, togglesplit, # dwindle

        # Copy a full-screen screenshot to clipboard using Print Screen
        bind = , Print, exec, grim - | wl-copy && notify-send "Screen Captured" "Saved to Clipboard"

        # Save a full-screen screenshot to the ~/Pictures directory using Super (Mod) + F12
        bind = $mainMod, F12, exec, grim ~/Pictures/Screenshot-$(date +'%Y-%m-%d-%H-%M-%S').png && notify-send "Screen Captured" "Saved to ~/Pictures"
        
        # Move focus with mainMod + arrow keys
        bind = $mainMod, left, movefocus, l
        bind = $mainMod, right, movefocus, r
        bind = $mainMod, up, movefocus, u
        bind = $mainMod, down, movefocus, d
        bind = $mainMod, ESCAPE, fullscreen
        
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
        
        # Scroll through existing workspaces with mainMod SHIFT + arrows
        bind = $mainMod SHIFT, right, workspace, e+1
        bind = $mainMod SHIFT, left, workspace, e-1
        
        # Move/resize windows with mainMod + LMB/RMB and dragging
        bindm = $mainMod, mouse:272, movewindow
        bindm = $mainMod, mouse:273, resizewindow
        
        '';

        dconf.settings = {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
          };
        };

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
        
        services.mako = {
          enable = true;
        
          settings = {
            # ---------- global look ----------
            background-color = "#282a36";
            text-color       = "#F8F8F2";
            border-color     = "#BD93F9";
        
            # ---------- behaviour ----------
            default-timeout  = 5000;        # 5 s
        
            # ---------- per‑urgency colours ----------
            "urgency=low" = {
              border-color = "#8BE9FD";
            };
            "urgency=normal" = {
              border-color = "#BD93F9";
            };
            "urgency=high" = {
              border-color = "#FF5555";
            };
          };
        };

        services.swayidle = {
          enable = true;

          timeouts = [
            {
              timeout = 300;
              command = "${pkgs.swaylock-effects}/bin/swaylock -f --screenshots --effect-blur 8x8 --effect-vignette 0.8:0.8 --text-color ffffff --grace 0 --fade-in 0.5 -F";
            }
          ];
        };

        home.packages = with pkgs; [

          #Python
          (python3.withPackages (ps: with ps; [ requests ]))

          #Gnome Applications
          eog
          gnome-disk-utility
          seahorse
          zenity

          #System
          libnotify
          appimage-run
          blueman
          gimp
          signal-desktop
          steam           
          xfce.thunar
          xfce.tumbler
          pavucontrol
          links2
          wget
          vlc
          ffmpeg
          mpv
          rofi-wayland
          swayosd
          swaylock-effects
          hyprpaper
          vscode.fhs
          imagemagick
          neofetch
          waypipe
          gparted
          rpi-imager
          dust
          btop
          pika-backup
          brightnessctl
          pamixer
          usbutils
          pciutils
          nmap
          chromium
          wl-clipboard
          grim
          zoom-us
          tmux
          assistant.packages.${system}.assistant
        ];
          
        home.stateVersion = "24.05";
      };

      environment.interactiveShellInit = ''
        neofetch
      '';

      environment.etc."assets".source = pkgs.fetchFromGitHub {
        owner = "fursman";
        repo = "NixOS-Assets";
        rev = "main";
        sha256 = "sha256-ZNgllzd3SdFvOUEcH99gFlEgP8yl+4++M8mtua72SYc=";
      };
      environment.etc."assets".target = "assets";
  
      environment.systemPackages = [ pkgs.swayosd ];
      services.udev.packages = [ pkgs.swayosd ];
  
      systemd.services.swayosd-libinput-backend = {
        description = "SwayOSD LibInput backend for listening to certain keys like CapsLock, ScrollLock, VolumeUp, etc.";
        documentation = [ "https://github.com/ErikReider/SwayOSD" ];
        wantedBy = [ "graphical.target" ];
        partOf = [ "graphical.target" ];
        after = [ "graphical.target" ];
  
        serviceConfig = {
          Type = "dbus";
          BusName = "org.erikreider.swayosd";
          ExecStart = "${pkgs.swayosd}/bin/swayosd-libinput-backend";
          Restart = "on-failure";
        };
      };

    });

    # Define the desktop configuration inline, previously contained in desktop.nix
    desktopConfiguration = { config, pkgs, ... }: {
      nix = {
        package = pkgs.nixVersions.stable;
        extraOptions = ''
          experimental-features = nix-command flakes
        '';
      };

      # Enable plymouth
      boot.plymouth = {
        enable = true;
        theme = "abstract_ring";
        themePackages = [(pkgs.adi1090x-plymouth-themes.override {selected_themes = ["abstract_ring"];})];
      };
    
      # Bootloader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.initrd.systemd.enable = true;
      boot.initrd.verbose = false;
      boot.loader.timeout = 0;
      boot.consoleLogLevel = 0;
      boot.kernelParams = [ "quiet" "splash" ];
    
      boot.supportedFilesystems = [ "ntfs" ];
    
      networking.hostName = "NixOS"; # Define your hostname.
      # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    
      # Configure network proxy if necessary
      # networking.proxy.default = "http://user:password@proxy:port/";
      # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
    
      # Enable networking
      networking.networkmanager.enable = true;

      # RTL-SDR
      hardware.rtl-sdr.enable = true;
    
      # Bluethooth
      hardware.bluetooth.enable = true;
      services.blueman.enable = true;
    
      # Set your time zone.
      time.timeZone = "America/Vancouver";
    
      # Select internationalisation properties.
      i18n.defaultLocale = "en_CA.UTF-8";
    
      # Enable the X11 windowing system.
      services.xserver.enable = true;
    
      # Enable Greeter
      services.xserver.displayManager.gdm.wayland = true;
      services.xserver.displayManager.gdm.enable = true;
    
      # Enagle the gnome-keyring
      services.gnome.gnome-keyring.enable = true;
      security.pam.services.greetd.enableGnomeKeyring = true;
    
      # Enable the GNOME Desktop Environment.
      # services.xserver.desktopManager.gnome.enable = true;
    
      # Enable Mouse in Hyprland
      environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
    
      # Enable Hyprlnd
      programs.hyprland.enable = true;
    
      # Enable xfce dbus communication (for Thunar)
      services.dbus.packages = with pkgs; [
        xfce.xfconf
      ];
    
      # Fonts Packages
      fonts.packages = with pkgs; [
        font-awesome
      ];
    
      # Enable Fonts
      fonts.fontconfig.enable = true;
    
      # Enable GVfs
      services.gvfs.enable = true;
    
      # Enable PAM Config for Swaylock-effects
      security.pam.services.swaylock = {
        text = ''
          auth include login
        '';
      };
    
      # Configure keymap in X11
      services.xserver = {
        xkb.layout = "us";
        xkb.variant = "";
      };
    
      # Enable CUPS to print documents.
      services.printing.enable = true;
    
      # Enable sound with pipewire.
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        #jack.enable = true;
    
        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        #media-session.enable = true;
      };
    
      # Enable touchpad support (enabled default in most desktopManager).
      # services.xserver.libinput.enable = true;

      # Enable OpenGL
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      hardware.nvidia-container-toolkit.enable = true;

      # Load nvidia driver for Xorg and Wayland
      services.xserver.videoDrivers = ["nvidia"];
      hardware.nvidia = {
    
        # Modesetting is required.
        modesetting.enable = true;
    
        # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
        powerManagement.enable = false;
        # Fine-grained power management. Turns off GPU when not in use.
        # Experimental and only works on modern Nvidia GPUs (Turing or newer).
        powerManagement.finegrained = false;
    
        # Use the NVidia open source kernel module (not to be confused with the
        # independent third-party "nouveau" open source driver).
        # Support is limited to the Turing and later architectures. Full list of 
        # supported GPUs is at: 
        # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
        # Only available from driver 515.43.04+
        # Currently alpha-quality/buggy, so false is currently the recommended setting.
        open = false;
    
        # Enable the Nvidia settings menu,
        # accessible via `nvidia-settings`.
        nvidiaSettings = true;
    
        # Optionally, you may need to select the appropriate driver version for your specific GPU.
        package = config.boot.kernelPackages.nvidiaPackages.beta;
      };
    
      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;
    
      # List packages installed in system profile. To search, run:
      # $ nix search wget
      environment.systemPackages = with pkgs; [
        git
        ntfs3g
        sdrpp
        dive # look into docker image layers
        podman-tui # status of containers in the terminal
        podman-desktop
        docker-compose # start group of containers for dev
        kubectl
        #podman-compose # start group of containers for dev
      ];
    
      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.user = {
        isNormalUser = true;
        description = "user";
        extraGroups = [ 
          "networkmanager"
          "wheel"
          "libvirtd" #Necessary for virt-manager
        ];
      };

      # Virtualization Settings
      virtualisation = {
        libvirtd = {
          enable = true;
          qemu.ovmf.enable = false;
        };

        containers.enable = true;
  
        podman = {
          enable = true;
    
          # Create a `docker` alias for podman, to use it as a drop-in replacement
          dockerCompat = true;
    
          # Required for containers under podman-compose to be able to talk to each other.
          defaultNetwork.settings.dns_enabled = true;
        };
      };

      programs.virt-manager.enable = true;
    
      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      # programs.mtr.enable = true;
      # programs.gnupg.agent = {
      #   enable = true;
      #   enableSSHSupport = true;
      # };
    
      # List services that you want to enable:
      # Enable the OpenSSH daemon.
      services.openssh.enable = true;
    
      # Open ports in the firewall.
      # networking.firewall.allowedTCPPorts = [ ... ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      # networking.firewall.enable = false;
    
      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "24.05"; # Did you read the comment?

  };
  in
  {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hardware-configuration.nix
          desktopConfiguration
          sharedConfiguration
        ];  
      };  
      blade = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hardware-configuration.nix
          server3080Nix
          sharedConfiguration
        ];  
      };
      block = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hardware-configuration.nix
          server4090Nix
          sharedConfiguration
        ];  
      };      
      pile = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hardware-configuration.nix
          serverTitanVNix
          sharedConfiguration
        ];  
      };     
      mbp = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hardware-configuration.nix
          inputs.nixos-hardware.nixosModules.apple-macbook-pro-14-1
          MacBookProNix
          sharedConfiguration
        ];  
      };     
      mini = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hardware-configuration.nix
          MacMiniNix
          sharedConfiguration
        ];  
      };     
      pi3 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./hardware-configuration.nix
          Pi3Nix
          sharedConfiguration
        ];  
      };   
      pi4 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./hardware-configuration.nix
          Pi4Nix
          sharedConfiguration
        ];  
      };
    };
  }; 
}
