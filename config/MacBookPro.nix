{ config, pkgs, lib, ... }:

########################################################################
# Overlay: adds apple‑spi + cs8409 audio as clean kernel‑module packages
########################################################################
let
  appleMbpOverlay = final: prev: {
    # ----- Apple SPI input ------------------------------------------------
    apple-spi-driver =
      prev.linuxPackages.callPackage (import ./overlays/apple-spi-driver.nix) {};

    # ----- Cirrus CS8409 audio codec --------------------------------------
    macbookpro-cs8409 =
      prev.linuxPackages.callPackage (import ./overlays/macbookpro-cs8409.nix) {};
  };
in
{
  nixpkgs.overlays = [ appleMbpOverlay ];

  ##########################################################################
  ##  Kernel & boot
  ##########################################################################
  boot.kernelPackages      = pkgs.linuxPackages_latest;

  # choose ONE loader: systemd‑boot for this MacBook
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;        # <── add this line

  boot.extraModulePackages = [
    pkgs.apple-spi-driver
    pkgs.macbookpro-cs8409
  ];

  boot.kernelModules = [
    "applespi" "apple_spi_keyboard" "apple_spi_touchpad"
    "snd_hda_macbookpro"
  ];
  boot.blacklistedKernelModules = [ "snd_hda_codec_cs8409" ];

  boot.kernelParams = [
    "snd-intel-dspcfg.dsp_driver=1"
    "snd_hda_intel.probe_mask=1"
  ];

  ##########################################################################
  ##  Firmware & Bluetooth
  ##########################################################################
  nixpkgs.config.allowUnfree             = true;
  hardware.enableRedistributableFirmware = true;
  hardware.firmware                      = with pkgs; [ broadcom-bt-firmware ];
  hardware.bluetooth.enable              = true;
  services.blueman.enable                = true;

  ##########################################################################
  ##  Desktop stack
  ##########################################################################
  services.xserver.enable                       = true;
  services.xserver.displayManager.gdm = {
    enable  = true;
    wayland = true;
  };

  programs.hyprland.enable                      = true;
  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
  services.gnome.gnome-keyring.enable           = true;

  ##########################################################################
  ##  PipeWire audio
  ##########################################################################
  services.pulseaudio.enable  = false;
  security.rtkit.enable       = true;
  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
    jack.enable       = true;
    wireplumber.enable = true;
    extraConfig.pipewire."context.properties" = {
      "default.clock.rate"        = 48000;
      "default.clock.quantum"     = 32;
      "default.clock.min-quantum" = 32;
      "default.clock.max-quantum" = 32;
    };
  };

  ##########################################################################
  ##  Input, fonts, locale
  ##########################################################################
  services.libinput.enable = true;
  services.libinput.touchpad.tapping = false;

  fonts.fontconfig.enable = true;

  networking.hostName              = "MacBookPro-Nix";
  networking.networkmanager.enable = true;
  time.timeZone                     = "America/Vancouver";
  i18n.defaultLocale                = "en_CA.UTF-8";

  ##########################################################################
  ##  Packages & users
  ##########################################################################
  environment.systemPackages = with pkgs; [
    git ntfs3g sdrpp dive podman-tui podman-desktop docker-compose
  ];

  users.users.user = {
    isNormalUser = true;
    description  = "user";
    extraGroups  = [ "networkmanager" "wheel" "libvirtd" ];
  };

  ##########################################################################
  ##  Virtualisation & SSH
  ##########################################################################
  virtualisation = {
    libvirtd.enable = true;
    containers.enable = true;
    podman = {
      enable       = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  services.openssh.enable = true;

  ##########################################################################
  system.stateVersion = "24.05";
}
