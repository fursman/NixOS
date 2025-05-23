# MacBookPro.nix  –  host‑specific settings for A1708 / MacBookPro14,1
{ config, pkgs, lib, ... }:

let
  inherit (pkgs) fetchFromGitHub callPackage;
in
{
  ############################################################
  ##  Built‑in keyboard & trackpad (SPI bus)
  ############################################################
  boot.extraModulePackages = [
    (callPackage (fetchFromGitHub {
      owner  = "roadrunner2";
      repo   = "macbook12-spi-driver";
      rev    = "f5c0528d1e977b0f3c8305f4c2ce97ec4a949e55";  # good for 6.8 / 6.9
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # ← fix‑me
    }) { })
  ];

  # add the SPI modules _after_ any others that may come from imports
  boot.kernelModules = lib.mkAfter [
    "apple_spi_driver"
    "apple_spi_keyboard"
    "apple_spi_touchpad"
  ];

  ############################################################
  ##  Bluetooth (Broadcom BCM43xx)
  ############################################################
  nixpkgs.config.allowUnfree = true;
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = with pkgs; [ broadcom-bt-firmware ];
  hardware.bluetooth.enable = true;
  services.blueman.enable   = true;

  ############################################################
  ##  Bootloader + kernel
  ############################################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;
  boot.consoleLogLevel = 0;
  boot.initrd = {
    systemd.enable  = true;
    verbose         = true;
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.supportedFilesystems = [ "ntfs" ];

  ############################################################
  ##  Host basics
  ############################################################
  networking.hostName = "MacBookPro-Nix";
  networking.networkmanager.enable = true;
  hardware.rtl-sdr.enable = true;
  time.timeZone           = "America/Vancouver";
  i18n.defaultLocale      = "en_CA.UTF-8";

  ############################################################
  ##  X11, Wayland & desktop environment
  ############################################################
  services.xserver.enable = true;
  services.xserver.displayManager.gdm = {
    enable  = true;
    wayland = true;
  };
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
  programs.hyprland.enable = true;

  services.dbus.packages = with pkgs; [ xfce.xfconf ];
  services.gvfs.enable   = true;

  services.xserver.xkb = {
    layout  = "us";
    variant = "";
  };

  ############################################################
  ##  Sound  (PipeWire)
  ############################################################
  services.pulseaudio.enable = false;
  security.rtkit.enable      = true;
  services.pipewire = {
    enable          = true;
    alsa.enable     = true;
    alsa.support32Bit = true;
    pulse.enable    = true;
    jack.enable     = true;
    wireplumber.enable = true;
    extraConfig.pipewire."context.properties" = {
      "default.clock.rate"        = 48000;
      "default.clock.quantum"     = 32;
      "default.clock.min-quantum" = 32;
      "default.clock.max-quantum" = 32;
    };
  };

  services.libinput = {
    enable            = true;
    touchpad.tapping  = false;   # disable tap‑to‑click
  };

  ############################################################
  ##  Fonts & printing
  ############################################################
  fonts = {
    packages = with pkgs; [ font-awesome ];
    fontconfig.enable = true;
  };
  services.printing.enable = true;

  ############################################################
  ##  Packages, users, virtualisation, etc.  (unchanged)
  ############################################################
  environment.systemPackages = with pkgs; [
    git ntfs3g sdrpp dive podman-tui podman-desktop docker-compose
  ];

  users.users.user = {
    isNormalUser = true;
    description  = "user";
    extraGroups  = [ "networkmanager" "wheel" "libvirtd" ];
  };

  virtualisation = {
    libvirtd.enable = true;
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
  programs.virt-manager.enable = true;

  ############################################################
  ##  OpenSSH & firewall
  ############################################################
  services.openssh.enable    = true;
  # networking.firewall.enable = false;   # uncomment if you disable FW

  system.stateVersion = "24.05";
}
