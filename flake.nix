{
  description = "flake for RBS17 with Home Manager enabled";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    wallpapers = {
      url = "github:fursman/wallpaper";
      flake = false;
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    home-manager,
    ...
  }: {

    nixosConfigurations = {

      RBS17 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./Stealth17.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.user = { pkgs, ... }: {
              home.username = "user";
              home.homeDirectory = "/home/user";
              programs.home-manager.enable = true;
              programs.firefox.enable = true;
              home.packages = with pkgs; [
                gimp
                signal-desktop
                steam           
                xfce.thunar
                gnome.eog
                links2
                wget
                vlc
                kitty
                rofi-wayland
                waybar
                swayosd
                brightnessctl
                hyprpaper
                swaylock-effects
                wlogout
                vscode.fhs
                imagemagick
              ];
              gtk.theme.name = nixpkgs.lib.mkDefault "Adwaita-dark";
              home.stateVersion = "23.11";
            };
          }
        ];
      };

      RBS12 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.user = { pkgs, ... }: {
              home.username = "user";
              home.homeDirectory = "/home/user";
              programs.home-manager.enable = true;
              programs.firefox.enable = true;
              home.packages = with pkgs; [
                gimp
                signal-desktop
                xfce.thunar
                gnome.eog
                links2
              ];
              gtk.theme.name = nixpkgs.lib.mkDefault "Adwaita-dark";
              home.stateVersion = "23.11";
            };
          }
        ];
      };

    };
  };
}
