# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, lib, config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  environment.systemPackages = with pkgs; [
    nixos-generators
    cifs-utils
    vim
    git

    # Virtualization
    virt-manager

    # Audio
    pulseaudio
    pamixer
  ];
  programs.thunar.enable = true;

  # Bootloader.
  boot.loader.systemd-boot = {
    enable = true;
    netbootxyz.enable = true;
    memtest86.enable = true;
    editor = false;
  };
  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
    enable = true;
    windowManager.qtile.enable = true;
    windowManager.qtile.extraPackages = p: with p; [ qtile-extras ]; 
    displayManager.lightdm.enable = true;
  };
  
  nix = {
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      auto-optimise-store = true;
    };

    extraOptions = ''
      experimental-features = nix-command flakes

      keep-outputs = true
      keep-derivations = true
      cores = 4
      max-jobs = 6
      max-free = ${toString (500*1024*1024)}
    '';
    
    gc = {
      automatic = true;
      dates = "weekly";
      options = "";
    };
  };
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ryan = {
    isNormalUser = true;
    description = "ryan";
    extraGroups = [ "networkmanager" "wheel" "podman" "libvirtd" "audio" "" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCjL6VXXuid4Dq7QbRUPgpFxqOvyNstWtOt/LXiGBPdtQRx979YNI27KtP8x+ysYifrcU0cksfetaHj5UZCEmre5iG78vZ4/svtouEjh6oCUGwCTrVUCN63cuTKtDSTAzBGd/jBFyUZo1SBAtpuQ/gKKvAX6WK1OcAg8SRSpeOhjK4r/jT/2vNEkJePNDJk+uw5uQdHynqrt+eSF6aQG7SZo+nG3S55MdWnlRuKIEfOOq0jt09SPxJ8GB0HpjvZhON/KdjHlAZDUPVui2bBhF0S/umzMyCsR6z3478uGijM9QcMGlpV8RjTqDa5BnngaKoNLc6RnFHjhdkEVLBVJVBUpjsnQbp8oYHMhbzTNgisuuiSHJUtljUIGIcLAe76Yxp3+lUPSYFzxZZp7m+sKUPnHYn/guVdUzJzk6nQXJiwoaV5vXMLsrWPMQJIwNpruGbUID3gkmhS0rs7y1TR0pHjcqfUlHWSrYqIB7gETsCJUjHOiGQm138BVsvYlnz9AH0= ryan@fedora"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCHqmSLKCBzV4VEdq/ey2UdtAo+H1dPGFh/MAMqrCMJxnwwTH7aYtKQmCr0e91fbCkmqRLwtVbX5keSwbpOWACAnPNuxCSuazuJ/PCKEcbTG92iZfK1tsbkd+JniLybn1wHtFPOGyvQpzNpKWVdFMiH0jbzxbrfYOVLiUacCsRiSWFLeS52KOgVzNckeZaJwQE+2Y40rCf1UTfI53FH4C+0SKQLNk9tqCgWaraDhZCrAhMwlRzsV6lWbCyCZMkO4Q92SQPhJdQ2y9eJ0A4x5WQE2YZVFmQTFQ5+nZZnLxhOmuJnUpwBAifU8PP7TwAVBzb4o1fm6TYfIjpj5HVD364E9MwEChyf3+XgIESmzSsr+XES6GaGF29m5LLYgM3spAbJviLTfjYIMGwpVSXW+j8HWxzhDDEZNC/6AAuuhdWRQYyQWcA72yPsMpKXaDH0PT3EeqABUx/uySKW+BAYLODG78Tft6gCbIBWseujlQywij2l5T3muABnHD86nbpbhKE= ryan@arch.fedora"
    ];
  };

  # audio 

  # security.rtkit.enable = true;
  # sound.enable = true;
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

    android_sdk.accept_licence = true;
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget


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


  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    package = pkgs.bluezFull;
    settings = { General = { Enable = "Source,Sink,Media,Socket"; }; };
  };services.blueman.enable = true;

  # Virtualization
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

  # required for podman
  programs.dconf.enable = true;

  # Security
  security.sudo.wheelNeedsPassword = false;

  system = {
    autoUpgrade = {
      enable = true;
      allowReboot = false;
      dates = "7:30";
    };

    stateVersion = "23.05"; # https://nixos.org/nixos/options.html
  };

  # Locale
  time.timeZone = "America/Regina";
  i18n.defaultLocale = "en_CA.UTF-8";
}
