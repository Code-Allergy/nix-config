# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, lib, config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  #boot.loader.grub.device = "/dev/vda";



  # Set your time zone.
  time.timeZone = "America/Regina";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
    enable = true;
    # desktopManager.plasma5.enable = true;
    windowManager.qtile.enable = true;
    windowManager.qtile.extraPackages = p: with p; [ qtile-extras ]; 
    #windowManager.qtile.backend = "wayland";
    displayManager.sddm.enable = true;
  };
  
  nix = {
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ryan = {
    isNormalUser = true;
    description = "ryan";
    extraGroups = [ "networkmanager" "wheel" "podman" "libvirtd" "audio" ];
  };

  # audio 

  # security.rtkit.enable = true;
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  # };

  # hardware.pulseaudio = {
  #   enable = false;
  #   package = pkgs.pulseaudioFull;
  # };


  # Enable automatic login for the user.
  services.getty.autologinUser = "ryan";

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nixos-generators
    cifs-utils
    vim
    git
    virt-manager
    pulseaudio
    pamixer
  ];
  programs.thunar.enable = true;

 fileSystems = let
   SambaConfigCommon = 
   {
    fsType = "cifs";
    options = let
    automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in ["${automount_opts},credentials=/etc/nixos/samba-creds,uid=1000,gid=100"];
   };
   in
   {
    "/mnt/ryan" = (SambaConfigCommon // { device = "//192.168.1.112/Ryan"; });
    "/mnt/games" = (SambaConfigCommon // { device = "//192.168.1.112/Games"; });
    "/mnt/media" = (SambaConfigCommon // { device = "//192.168.1.112/Media"; });
    "/mnt/ingest" = (SambaConfigCommon // { device = "//192.168.1.112/Ingest"; });
   };

  
  fonts = {
    fonts = with pkgs; [
      montserrat

      roboto
      roboto-mono
      
      fira-code
      fira-code-symbols
      (nerdfonts.override { fonts = [ "FiraCode" "IBMPlexMono" "RobotoMono"]; })
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        # serif
        sansSerif = [ "Montserrat" ];
        monospace = [ "BlexMono Nerd Font" ];
      };
    };
  };


  # Network config
  networking = {
    hostName = "blubbus";
    networkmanager = {
      enable = true;
      wifi.powersave = true;
    };

    firewall = {
      allowedTCPPorts = [  ];
      allowedUDPPorts = [  ];
      enable = true;
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
#      PasswordAuthentication = false;
    };
  };

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
    };

    libvirtd = {
      enable = true;
      qemu.ovmf.enable = true;
    };
    spiceUSBRedirection.enable = true;
    # anbox.enable = true;
  };
  # services.qemuGuest.enable = true;

  # required for podman
  programs.dconf.enable = true;

  system = {
    autoUpgrade = {
      enable = true;
      allowReboot = false;
      dates = "7:30";
    };

    stateVersion = "23.05"; # https://nixos.org/nixos/options.html
  };
}
