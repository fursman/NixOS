
# README.md for NixOS Configuration using Home Manager and Flakes

## Introduction

This repository offers a simple yet powerful way to install and configure a NixOS environment tailored to a modern linux desktop workflow with GPU acceleration for containers and virtual environments. It leverages NixOS's reproducibility and the flake system to create a consistent and portable setup.

## Quick Start

1. **Initial Installation**: Install a minimal ISO NixOS from [NixOS Download](https://nixos.org/download).
2. **Network Connection**: Connect with an Ethernet cable or use Network Monitor CLI `nmcli <device> wifi connect <mySSID> password <myPassword>` for a wireless connection.
3. **Download `flake.nix` to `/etc/nixos/`**:
   ```bash
   # Change directory to the NixOs configurations home.
   cd /etc/nixos
   # Open a temporary shell with wget to fetch web files.
   nix-shell -p wget
   sudo wget https://raw.githubusercontent.com/fursman/NixOS/main/flake.nix
   ```
5. **Apply Configuration**: Rebuild NixOS with flakes, home manager and custom configurations.
   ```bash
   # Must be executed from within the /etc/nixos working directory.
   "sudo nixos-rebuild --flake .#desktop switch"
   ```

## What's Inside?

### `flake.nix`
- **Description**: "flake for a desktop environment with Home Manager enabled."
## Inputs

- **nixpkgs**: Points to the NixOS unstable branch.
- **home-manager**: References the home-manager package from the nix-community repository.
- **home-manager.inputs.nixpkgs.follows**: Ensures home-manager follows the nixpkgs version.

## Outputs

The outputs are generated by a function that takes `inputs` and configures the NixOS environment.

## Resources

Fetches various configuration files and scripts from a remote repository:

- **styleCss**: Waybar style CSS.
- **weatherScript**: Python script for weather information.
- **spotlightDarkRasi**: Rofi theme.
- **desktopNix**: Main desktop configuration.

## NixOS Configurations

## Desktop Configuration

- **System Architecture**: x86_64-linux.
- **Modules**: Includes hardware configuration, desktop configuration, and custom configurations.

## Home Manager Integration

- Enables Home Manager for NixOS.
- Configures user environment with various settings, themes, and packages.
  
## Key User Configurations:

- **Rofi theme**: Sets up a custom Rofi theme.
- **Wallpaper Management**: Configures dynamic wallpapers.
- **Pointer Cursor**: Adwaita cursor theme with customization.
- **Kitty Terminal**: Customizes Kitty terminal settings.
- **Waybar**: Configures Waybar with modules for system monitoring and functionality.
- **Hyprland Wayland Compositor**: Enables and configures Hyprland with a detailed setup.
- **GTK Themes**: Sets up Dracula themes for GTK applications.
- **Firefox**: Enables Firefox with specific settings.
- **Package List**: A curated list of packages for the user's environment.
- **System State Version**: Defines the NixOS state version.

### `desktop.nix (dynamically linked)`
- **Machine Learning Desktop Specific Configurations**
- **Nix Configuration**: Enables Nix Flakes.
- **Plymouth Boot Screen**: Graphical boot screen setup.
- **Bootloader Settings**: Configures `systemd-boot` and EFI.

### Custom Configurations
- **Hyprland**: Wayland compositor setup.
- **Waybar**: Customized Wayland bar.
- **Rofi**: Window switcher and application launcher.
- **Kitty**: GPU-based terminal emulator.

### Key Software
- **VS Code**: Primary code editor.
- **Podman-Desktop**: Container management.
- **Virt-Manager**: Virtual environment management.
- **Thunar**: File manager.
- **Firefox**: Web browser.
- **Swaylock**: Session locking.
- **Wlogout**: Session logout interface.

## License

"Do what thou wilt shall be the whole of the Law"
