
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
- **Inputs**: 
  - `nixpkgs`: Points to `nixos-unstable`.
  - `home-manager`: From `nix-community/home-manager`.
  - `wallpapers`: Custom repository for desktop wallpapers.
- **Outputs**: Configurations for Nix packages and Home Manager.

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


## Detailed Explanation of `flake.nix`

The `flake.nix` file is a central component of this NixOS configuration, defining the inputs and outputs for the system's environment. It provides a reproducible and modular setup that allows for easy updates and customization.

- **Inputs** include `nixpkgs` for the NixOS packages, `home-manager` for user environment management, and custom resources like wallpapers.
- **Outputs** describe the system and user configurations, integrating various modules and packages for a cohesive desktop environment.

This file includes custom configurations for key software like Waybar, Rofi, Kitty, and Hyprland, ensuring an optimal setup for a modern desktop experience.

## Detailed Explanation of `desktop.nix`

The `desktop.nix` file specifies the system-wide settings and configurations for the NixOS environment.

- **System Settings**: Configures basic system parameters like networking, Bluetooth, time zone, and internationalization.
- **Desktop Environment**: Sets up the GNOME desktop environment, X11 windowing system, and Wayland compositor settings.
- **Package Management**: Lists essential packages for the system, including Git, NTFS support, and Podman Desktop for container management.
- **User Configuration**: Defines user-specific settings and group permissions, along with virtualization tools like Virt-Manager.

Overall, `desktop.nix` ensures a robust and user-friendly desktop experience, tailored for both developers and general users.

