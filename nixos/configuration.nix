# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
    ./environments/hyprland.nix
    ./environments/plasma.nix
    ./samba-mounts.nix
    ./virtualisation.nix
    ./fonts.nix
    ./flatpak.nix

    # TMP
    ./vpn.nix
    # <home-manager/nixos>
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    users = {
      # Import your home-manager configuration
      ryan = import ../home-manager/home.nix;
    };
  };

  # Enable TRIM for ssds
  services.fstrim.enable = lib.mkDefault true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.android_sdk.accept_licence = true;

  nix = {
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    extraOptions = ''
      experimental-features = nix-command flakes
      auto-optimise-store = true
      keep-outputs = true
      keep-derivations = true
      cores = 4
      max-jobs = 6
      max-free = ${toString (500 * 1024 * 1024)}
    '';

    gc = {
      automatic = true;
      dates = "weekly";
      options = "";
    };
  };
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #  boot.loader.grub.device = "nodev";
  #  boot.loader.grub.efiSupport = true;

  networking.hostName = "bigblubbus"; # Define your hostname.

  # TODO blubbus networking
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  time.timeZone = "America/Regina";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  programs.gamemode.enable = true;
  programs.gamemode.settings = {
    gpu.apply_gpu_optimisations = "accept-responsibility";
    gpu.device = 1;
    custom = {
      start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
      end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
    };
  };

  # AMD
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  boot.initrd.kernelModules = ["amdgpu"];

  systemd.tmpfiles.rules = let
    rocmEnv = pkgs.symlinkJoin {
      name = "rocm-combined";
      paths = with pkgs.rocmPackages; [
        rocblas
        hipblas
        clr
      ];
    };
  in [
    "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
  ];

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim-full
    mupdf
    wget
    git
    qemu
    corectrl

    lact
    kdePackages.polkit-kde-agent-1
    xorg.xrandr # TMP

    # dotfiles
    git-crypt
    stow

    # add distrobox
    distrobox
    boxbuddy
  ];

  systemd.packages = with pkgs; [lact];
  systemd.services.lactd.wantedBy = ["multi-user.target"];

  # TODO TEMP
  programs.steam.enable = true;
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  home-manager.useUserPackages = true;

  users.users.ryan = {
    isNormalUser = true;
    extraGroups = ["wheel" "docker" "libvirtd"];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCjL6VXXuid4Dq7QbRUPgpFxqOvyNstWtOt/LXiGBPdtQRx979YNI27KtP8x+ysYifrcU0cksfetaHj5UZCEmre5iG78vZ4/svtouEjh6oCUGwCTrVUCN63cuTKtDSTAzBGd/jBFyUZo1SBAtpuQ/gKKvAX6WK1OcAg8SRSpeOhjK4r/jT/2vNEkJePNDJk+uw5uQdHynqrt+eSF6aQG7SZo+nG3S55MdWnlRuKIEfOOq0jt09SPxJ8GB0HpjvZhON/KdjHlAZDUPVui2bBhF0S/umzMyCsR6z3478uGijM9QcMGlpV8RjTqDa5BnngaKoNLc6RnFHjhdkEVLBVJVBUpjsnQbp8oYHMhbzTNgisuuiSHJUtljUIGIcLAe76Yxp3+lUPSYFzxZZp7m+sKUPnHYn/guVdUzJzk6nQXJiwoaV5vXMLsrWPMQJIwNpruGbUID3gkmhS0rs7y1TR0pHjcqfUlHWSrYqIB7gETsCJUjHOiGQm138BVsvYlnz9AH0= ryan@fedora"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCHqmSLKCBzV4VEdq/ey2UdtAo+H1dPGFh/MAMqrCMJxnwwTH7aYtKQmCr0e91fbCkmqRLwtVbX5keSwbpOWACAnPNuxCSuazuJ/PCKEcbTG92iZfK1tsbkd+JniLybn1wHtFPOGyvQpzNpKWVdFMiH0jbzxbrfYOVLiUacCsRiSWFLeS52KOgVzNckeZaJwQE+2Y40rCf1UTfI53FH4C+0SKQLNk9tqCgWaraDhZCrAhMwlRzsV6lWbCyCZMkO4Q92SQPhJdQ2y9eJ0A4x5WQE2YZVFmQTFQ5+nZZnLxhOmuJnUpwBAifU8PP7TwAVBzb4o1fm6TYfIjpj5HVD364E9MwEChyf3+XgIESmzSsr+XES6GaGF29m5LLYgM3spAbJviLTfjYIMGwpVSXW+j8HWxzhDDEZNC/6AAuuhdWRQYyQWcA72yPsMpKXaDH0PT3EeqABUx/uySKW+BAYLODG78Tft6gCbIBWseujlQywij2l5T3muABnHD86nbpbhKE= ryan@arch.fedora"
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Open ports in the firewall.
  # TODO specify for computer

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22];
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      } # KDE Connect
    ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      } # KDE Connect
    ];
  };

  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_intel emulate_invalid_guest_state=0
    options kvm ignore_msrs=1
  '';

  # FS TODO blubbus (bigblubbus specific)
  fileSystems."/mnt/ssd0" = {
    device = "/dev/disk/by-uuid/b3cb05da-a6e5-4c73-9251-0e42daf1285e";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/a3e4489e-9ad2-4ada-b00a-17e94ea0a518";
    }
  ];

  # boot.resumeDevice = "/dev/disk/by-uuid/a3e4489e-9ad2-4ada-b00a-17e94ea0a518";

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # TODO this is bigblubbus specific (amd gpu OC enable)
  boot.kernelParams = [
    "amdgpu.ppfeaturemask=0xffffffff"
  ];

  system = {
    autoUpgrade = {
      enable = true;
      allowReboot = false;
      dates = "7:30";
    };

    # Do NOT change this value, For more information, see `man configuration.nix`
    # or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion.
    stateVersion = "24.05";
  };
}
