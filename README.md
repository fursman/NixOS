
# README.md for NixOS Configuration

## Introduction

Welcome to my NixOS configuration repository. This repository offers a simple yet powerful way to install and configure a NixOS environment, tailored to my personal workflow. It leverages NixOS's reproducibility and the flake system to create a consistent and portable setup.

## Quick Start

1. Install a minimal ISO NixOS from [NixOS Download](https://nixos.org/download).
2. Download the `flake.nix` file to `/etc/nixos`:
   ```bash
   wget https://raw.githubusercontent.com/fursman/NixOS/main/flake.nix
   ```
3. Apply the configuration:
   ```bash
   sudo nixos-rebuild --flake .#RBS17 switch
   ```

## What's Inside?

### `flake.nix`
- **Description**: "flake for RBS17 with Home Manager enabled."
- **Inputs**: 
  - `nixpkgs`: Points to `nixos-unstable`.
  - `home-manager`: From `nix-community/home-manager`.
  - `wallpapers`: Custom repository for desktop wallpapers.
- **Outputs**: Configurations for Nix packages and Home Manager.

### `stealth17.nix`
- **Nix Configuration**: Enables Nix Flakes.
- **Plymouth Boot Screen**: Graphical boot screen setup.
- **Bootloader Settings**: Configures `systemd-boot` and EFI.
- **(Additional system configurations)**

### Custom Configurations
- **Hyprland**: Wayland compositor setup.
- **Waybar**: Customized Wayland bar.
- **Rofi**: Window switcher and application launcher.
- **Kitty**: GPU-based terminal emulator.

### Key Software
- **VS Code**: Primary code editor.
- **Podman-Desktop**: Container management.
- **Thunar**: File manager.
- **Firefox**: Web browser.
- **Swaylock**: Session locking.
- **Wlogout**: Session logout interface.

## Detailed Usage

### Steps:
1. **Initial Setup**: Install NixOS and ensure internet connectivity.
2. **Downloading Configuration**: Use `wget` for `flake.nix`.
3. **Applying Configuration**: Execute `sudo nixos-rebuild`.
4. **Customization**: Modify `flake.nix` and `stealth17.nix` as needed.

## Contributing

Contributions are welcome! Please submit pull requests or issues for improvements or bugs.

## License

This project is licensed under the MIT License.
