# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, lib, config, pkgs, ... }:

{

  # Enable automatic login for the user.
  services.getty.autologinUser = "ryan";
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  environment.systemPackages = with pkgs; [
    nixos-generators
    cifs-utils
    vim
    git

    # Network
    networkmanagerapplet

    # Virtualization
    virt-manager

    # Audio
    pulseaudio
    pamixer
  ];
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce;[
    thunar-volman thunar-archive-plugin
  ];


  # Bootloader.
  boot = {
    loader.systemd-boot = {
      enable = true;
      netbootxyz.enable = true;
      memtest86.enable = true;
      editor = false;
    };
    plymouth = {
      enable = true;
      themePackages = [ pkgs.catppuccin-plymouth pkgs.nixos-bgrt-plymouth ];
      theme = "bgrt";
    };
    kernelParams = [ "quiet splash" ];
  };
  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    enable = true;
    windowManager.qtile.enable = true;
    windowManager.qtile.extraPackages = p: with p; [ qtile-extras ]; 
    displayManager.lightdm.enable = true;
  };
  
  nix = {
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    extraOptions = ''
      experimental-features = nix-command flakes
      auto-optimise-store = true
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
    extraGroups = [ "wheel" "networkmanager" "podman" "libvirtd" "audio" "video" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCjL6VXXuid4Dq7QbRUPgpFxqOvyNstWtOt/LXiGBPdtQRx979YNI27KtP8x+ysYifrcU0cksfetaHj5UZCEmre5iG78vZ4/svtouEjh6oCUGwCTrVUCN63cuTKtDSTAzBGd/jBFyUZo1SBAtpuQ/gKKvAX6WK1OcAg8SRSpeOhjK4r/jT/2vNEkJePNDJk+uw5uQdHynqrt+eSF6aQG7SZo+nG3S55MdWnlRuKIEfOOq0jt09SPxJ8GB0HpjvZhON/KdjHlAZDUPVui2bBhF0S/umzMyCsR6z3478uGijM9QcMGlpV8RjTqDa5BnngaKoNLc6RnFHjhdkEVLBVJVBUpjsnQbp8oYHMhbzTNgisuuiSHJUtljUIGIcLAe76Yxp3+lUPSYFzxZZp7m+sKUPnHYn/guVdUzJzk6nQXJiwoaV5vXMLsrWPMQJIwNpruGbUID3gkmhS0rs7y1TR0pHjcqfUlHWSrYqIB7gETsCJUjHOiGQm138BVsvYlnz9AH0= ryan@fedora"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCHqmSLKCBzV4VEdq/ey2UdtAo+H1dPGFh/MAMqrCMJxnwwTH7aYtKQmCr0e91fbCkmqRLwtVbX5keSwbpOWACAnPNuxCSuazuJ/PCKEcbTG92iZfK1tsbkd+JniLybn1wHtFPOGyvQpzNpKWVdFMiH0jbzxbrfYOVLiUacCsRiSWFLeS52KOgVzNckeZaJwQE+2Y40rCf1UTfI53FH4C+0SKQLNk9tqCgWaraDhZCrAhMwlRzsV6lWbCyCZMkO4Q92SQPhJdQ2y9eJ0A4x5WQE2YZVFmQTFQ5+nZZnLxhOmuJnUpwBAifU8PP7TwAVBzb4o1fm6TYfIjpj5HVD364E9MwEChyf3+XgIESmzSsr+XES6GaGF29m5LLYgM3spAbJviLTfjYIMGwpVSXW+j8HWxzhDDEZNC/6AAuuhdWRQYyQWcA72yPsMpKXaDH0PT3EeqABUx/uySKW+BAYLODG78Tft6gCbIBWseujlQywij2l5T3muABnHD86nbpbhKE= ryan@arch.fedora"
    ];
  };

  # Laptop TLP battery saving config
  services.tlp.enable = true;
  services.tlp.settings = { };

  # Enable acpi daemon so laptop close/open is responded to
  services.acpid.enable = true;


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.android_sdk.accept_licence = true;

 fileSystems = let
   SambaConfigCommon = 
   {
    fsType = "cifs";
    options = ["x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s," 
              "x-systemd.mount-timeout=5s,credentials=/etc/nixos/samba-creds,uid=1000,gid=100"];
   }; in
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

      noto-fonts
      noto-fonts-emoji
      
      fira-code
      fira-code-symbols
      (nerdfonts.override { fonts = [ "FiraCode" "IBMPlexMono" "RobotoMono" "Hack"]; })
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
      qemu.swtpm.enable = true;
    };
    spiceUSBRedirection.enable = true;

    oci-containers.containers = {
      # tdarr_node = {
      #   image = "ghcr.io/haveagitgat/tdarr";
      #   volumes = [
      #     "/etc/tdarr:/app/configs"
      #     "/var/log/tdarr:/app/logs"
      #     "/mnt/media:/media"
      #     "/mnt/ingest/Tcache:/temp"
      #   ];
      #   environment = {
      #     nodeName = "blubbus";
      #     serverIP = "192.168.1.112";
      #     serverPort = "8266";
      #     inContainer = "true";
      #     TZ = "America/Regina";
      #     PUID = "1000";
      #     PGID = "1000";
      #     NVIDIA_DRIVER_CAPABILITIES = "all";
      #     NVIDIA_VISIBLE_DEVICES = "all";
      #   };
      #   extraOptions = [
      #     "--gpus=all" "--device=/dev/dri:/dev/dri"
      #     "--network=bridge"
      #   ];
      # };


    };
  };

  # required for podman
  programs.dconf.enable = true;

  # Security
  security.sudo.wheelNeedsPassword = false;


  # System configuration
  system = {
    autoUpgrade = {
      enable = true;
      allowReboot = false;
      dates = "7:30";
    };
    stateVersion = "23.05"; # https://nixos.org/nixos/options.html
  };

  # Locale & Time
  time.timeZone = "America/Regina";
  services.chrony.enable = true;
  i18n.defaultLocale = "en_CA.UTF-8";
}
