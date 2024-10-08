# README.md for NixOS Configuration with virtualization and GPU acceleration using Home Manager and Flakes

## Introduction

This repository offers a simple yet powerful way to install and configure a NixOS environment tailored to a modern linux desktop workflow with GPU acceleration for containers and virtual environments. It leverages NixOS's reproducibility and the flake system to create a consistent and portable setup.

## Quick Start

1. **Initial Installation**: Install a minimal ISO NixOS from [NixOS Download](https://nixos.org/download).
2. **Network Connection**: Connect with an Ethernet cable or use Network Monitor CLI `nmcli device wifi connect <mySSID> password <myPassword>` for a wireless connection.
3. **Download `flake.nix` to `/etc/nixos/`**:
   ```bash
   # Change to the NixOs configuration working directory.
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
## Hyprland Environment User Manual

Welcome to the Hyprland Environment! This manual provides detailed instructions on how to utilize the key combinations defined in your Hyprland configuration file. Each key combination is designed to enhance your productivity and streamline your desktop experience.
Key Combinations and Their Functions

Launching Applications:

    Open Application Launcher: Press SUPER + RETURN to open Rofi, a program launcher that allows you to search for and launch applications installed on your system.
    Terminal: Press SUPER + T to open Kitty, a fast, feature-rich, GPU-based terminal emulator.
    Gaming: Press SUPER + G to launch Steam in Big Picture mode, providing an immersive gaming experience.
    Web Browsing: Press SUPER + B to open Firefox, a free and open-source web browser.
    File Management: Press SUPER + F to open Thunar, a fast and easy-to-use file manager.
    Audio Settings: Press SUPER + A to open Pavucontrol, a PulseAudio volume control tool.
    Code Editor: Press SUPER + C to launch Visual Studio Code, a source-code editor with support for debugging, syntax highlighting, intelligent code completion, snippets, and code refactoring.
    Virtual Machines: Press SUPER + V to open Virt-manager, a desktop user interface for managing virtual machines.
    Lock Screen: Press SUPER + L to lock the screen using Swaylock, enhancing your system's security with various customization options.
    Logout: Press SUPER + X to initiate a logout sequence with wlogout, a Wayland-based logout menu.
    Voice Assistant: Press SUPER + SPACE to start a background assistant process, useful for voice-controlled commands and tasks.

Window Management:

    Quit Active Window: Press SUPER + Q to close the active window.
    Toggle Window Split: Press SUPER + J to toggle the active window's split orientation, optimizing your workspace layout.
    Pseudo-Tiling: Press SUPER + P to enable pseudo-tiling mode, allowing windows to mimic tiling behavior without fully adhering to a tiling window manager's strict layout rules.

Workspace Management:

    Switching Workspaces: Press SUPER + [1-9,0] to switch between workspaces, offering a quick way to navigate across different groups of applications and windows. Workspace 1 through 9 are accessed through 1-9, and Workspace 10 is accessed with 0.
    Moving Windows to Workspaces: Press SUPER + SHIFT + [1-9,0] to move the active window to a specific workspace, facilitating organized task management and a cleaner desktop environment.

Focus Management:

    Move Focus: Use SUPER + [left/right/up/down arrow] to move the focus between windows in the specified direction. This feature allows you to navigate between your open windows with ease, improving multitasking efficiency.

## What's Inside?

### `flake.nix`
- **Description**: "NixOS flake for a desktop environment with Home Manager enabled."
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
- **desktopNix**: Main NixOS system configuration for desktop systems.
- **serverNix Files**: Alternatice NixOS system configurations for NVIDIA GPU passthrough on virtual systems using Virt-Manager.

## Desktop Configuration

- **System Architecture**: x86_64-linux.
- **Modules**: Includes hardware configuration, desktop configuration, and custom configurations.

## Home Manager Integration

- Enables Home Manager for NixOS.
- Configures user environment with various settings, themes, and packages.
  
## Key User Configurations:

- **Rofi theme**: Sets up a custom Rofi theme `spotlightDarkRasi` using the linked resource.
- **Wallpaper Management**: Configures dynamic wallpapers.
- **Pointer Cursor**: Adwaita cursor theme with customization.
- **Kitty Terminal**: Customizes Kitty terminal settings.
- **Waybar**: Configures Waybar with modules for system monitoring and functionality.
- **Hyprland Wayland Compositor**: Enables and configures Hyprland with a detailed setup.
- **GTK Themes**: Sets up Dracula themes for GTK applications.
- **Firefox**: Enables Firefox with specific settings.
- **Package List**: A curated list of packages for the user's environment.
  - **python3.withPackages (requests)**: Provides Python 3 along with the `requests` library, useful for scripting and automating HTTP requests.
  - **gimp**: An advanced image editing software, ideal for photo retouching, image composition, and image authoring.
  - **signal-desktop**: A secure messaging app that offers end-to-end encryption for text, voice, and video communication.
  - **steam**: A popular digital distribution platform for video gaming, offering a vast library of games, automatic game updates, and community features.
  - **xfce.thunar**: A fast and easy-to-use file manager from the XFCE desktop environment.
  - **gnome.eog**: Eye of GNOME, a simple and straightforward image viewer.
  - **links2**: A text and graphical web browser with a pull-down menu system.
  - **wget**: A free utility for non-interactive download of files from the web.
  - **vlc**: A versatile multimedia player that supports various audio and video formats.
  - **rofi-wayland**: A window switcher, application launcher, and dmenu replacement for Wayland.
  - **swayosd**: An on-screen display (OSD) for Sway and Wayland, useful for volume, brightness, and other notifications.
  - **brightnessctl**: A program to read and control device brightness.
  - **hyprpaper**: A wallpaper manager for Sway and Wayland, allows for dynamic wallpaper changes.
  - **swaylock-effects**: A fork of swaylock, adding effects like blur to the lock screen.
  - **wlogout**: A Wayland-based logout menu, useful for cleanly exiting the desktop session.
  - **vscode.fhs**: Visual Studio Code packaged with FHS (Filesystem Hierarchy Standard) support, a popular code editor with a wide range of extensions.
  - **gnome.seahorse**: A front-end for GnuPG, useful for encryption, signing, and key management.
  - **imagemagick**: A software suite to create, edit, compose, or convert bitmap images, supporting many image formats.
  - **Git**: Installs Git for version control.
  - **NTFS-3G**: Provides NTFS filesystem support, enabling read/write operations on NTFS partitions.
  - **Podman Desktop**: Installs Podman for managing OCI (Open Container Initiative) and Docker containers.
- **System State Version**: Defines the NixOS state version as 23.11

## System Configuration

- **Nix Flakes**: Enables experimental features for Nix, including Nix Flakes.
- **Plymouth**: Activates the Plymouth graphical boot splash screen.
- **Bootloader**: Configures systemd-boot with EFI support.
- **Filesystem Support**: Includes support for NTFS filesystems.
- **Networking**: Enables NetworkManager for network configuration and Bluetooth support.
- **Timezone**: Sets the system timezone to America/Vancouver.
- **Locale**: Specifies the default locale to `en_CA.UTF-8`.
- **X11 Windowing System**: Enables the X11 windowing system.
- **GNOME Keyring**: Integrates GNOME keyring for secure storage of credentials.
- **Hyprland**: Enables Hyprland, a Wayland compositor, with NVIDIA patches.
- **Fonts**: Includes Font Awesome in the system's font configuration.

## Hardware and Drivers

- **Bluetooth and Blueman**: Activates Bluetooth hardware support and Blueman services.
- **NVIDIA Drivers**: Configures NVIDIA drivers with modesetting and optional power management features.
- **OpenGL Support**: Enables OpenGL with support for 32-bit DRI (Direct Rendering Infrastructure).

## User Configuration

- **Default User Settings**: Defines a default user with access to network management and virtualization groups.
- **Virtualization Support**: Enables Podman for containerization and libvirt with Virt-Manager for virtualization management.
- **SSH Service**: Activates OpenSSH service for secure remote access.

## License

"Do what thou wilt shall be the whole of the Law"
