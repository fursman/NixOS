# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
        experimental-features = nix-command flakes
    '';
  };

  # These modules are required for PCI passthrough, and must come before early modesetting stuff
  boot.kernelModules = [
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
    "vfio_virqfd"
  
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];
  
  # CHANGE: Don't forget to put your own PCI IDs here (run lspci -nn and look for NVIDIA)
  boot.extraModprobeConfig ="options vfio-pci ids=10de:2684,10de:22ba";

  # Enable plymouth
  boot.plymouth = {
    enable = true;
    theme = "owl";
    themePackages = [(pkgs.adi1090x-plymouth-themes.override {selected_themes = ["owl"];})];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  boot.initrd.verbose = false;
  boot.loader.timeout = 0;
  boot.consoleLogLevel = 0;
  # Enable "quiet" output, "splash" screen and virtualization GPU options at boot
  boot.kernelParams = [ "quiet" "splash" "iommu=pt" "vfio_iommu_type1.allow_unsafe_interrupts=1" ];

  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName = "Pile"; # Define your hostname.
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
  #services.xserver.resolutions = [{ x = 3840; y = 2160; }];

  # Enable Greeter
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.displayManager.gdm.enable = true;

  # Enable the gnome-keyring
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

  # Configure ollama for local LLMs
  services.ollama = {
    enable = true;
    acceleration = "cuda";
    host = "0.0.0.0";
    port = 11434;
    openFirewall = true; 
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
    adi1090x-plymouth-themes
    sdrpp
    looking-glass-client
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    podman-desktop
    docker-compose # start group of containers for dev
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
      "plugdev"
      "kvm"
      "qemu-libvirtd"
    ];
  };

  # Virtualization Settings
  virtualisation = {

    libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu = {
        package = pkgs.qemu_kvm;
        ovmf = {
          enable = true;
        };
        swtpm.enable = true;
        runAsRoot = false;
      };
    };

    containers.enable = true;
  
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };

    # USB redirection in virtual machine
    spiceUSBRedirection.enable = true;
  };

  systemd.tmpfiles.rules = [
    ''f /dev/shm/looking-glass 0777 user qemu-libvirtd -''
  ];

  programs.dconf.enable = true;

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
  services.openssh = {
    enable = true;
    extraConfig = ''
      allowTcpForwarding yes
      gatewayPorts clientspecified
    '';
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 7860 8000 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
