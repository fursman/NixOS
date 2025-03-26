{ config, pkgs, ... }:

{
  # Import the KVMFR module options (and its build derivation, see kvmfr-package.nix)
  imports = [
    ./kvmfr-options.nix
  ];

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  boot.kernelModules = [
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
    "vfio_virqfd"
  ];
  
  boot.extraModprobeConfig = "options vfio-pci ids=10de:2684,10de:22ba";

  boot.plymouth = {
    enable = true;
    theme = "red_loader";
    themePackages = [
      (pkgs.adi1090x-plymouth-themes.override { selected_themes = [ "red_loader" ]; })
    ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  boot.initrd.verbose = false;
  boot.loader.timeout = 0;
  boot.consoleLogLevel = 0;
  boot.kernelParams = [ "quiet" "splash" "intel_iommu=on" "iommu=pt" ];

  boot.supportedFilesystems = [ "ntfs" ];

  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  time.timeZone = "America/Vancouver";

  i18n.defaultLocale = "en_CA.UTF-8";

  services.xserver.enable = true;

  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.displayManager.gdm.enable = true;

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  programs.hyprland.enable = true;
  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

  services.dbus.packages = with pkgs; [
    xfce.xfconf
  ];

  fonts.packages = with pkgs; [
    font-awesome
  ];

  fonts.fontconfig.enable = true;
  services.gvfs.enable = true;

  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  services.printing.enable = true;

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    ntfs3g
    adi1090x-plymouth-themes
    sdrpp
    looking-glass-client
  ];

  users.users.user = {
    isNormalUser = true;
    description = "user";
    extraGroups = [ 
      "networkmanager"
      "wheel"
      "libvirtd"  # Needed for virt-manager
      "kvm"
      "qemu-libvirtd"
    ];
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu = {
        package = pkgs.qemu_kvm;
        ovmf = { enable = true; };
        swtpm.enable = true;
        runAsRoot = false;
      };
    };

    spiceUSBRedirection.enable = true;

    # KVMFR configuration:
    kvmfr = {
      enable = true;
      shm = {
        enable = true;
        size = 128;
        user = "user";
        group = "libvirtd";
        mode = "0600";
      };
    };
  };

  programs.dconf.enable = true;
  programs.virt-manager.enable = true;

  services.openssh = {
    enable = true;
    extraConfig = ''
      allowTcpForwarding yes
      gatewayPorts clientspecified
    '';
  };

  networking = {
    hostName = "Block";
    firewall.allowedTCPPorts = [ 7860 8080 ];
  };

  system.stateVersion = "24.05";
}
