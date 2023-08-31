{pkgs, config, ...}:

{
  imports = [
      # ../nixos/common.nix
      ../../nixos/audio.nix
      ../../nixos/bluetooth.nix
      ../../nixos/samba-mounts.nix
      # ../nixos/hardware-configuration.nix
      ../../nixos/users/ryan
      ../../nixos/common.nix
  ];

  config = {
    environment.systemPackages = with pkgs; [
      # power management
      powertop
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
      kernelParams = [ "quiet" "splash" ];
    };
      # Locale & Time
      time.timeZone = "America/Regina";
      services.chrony.enable = true;
      i18n.defaultLocale = "en_CA.UTF-8";


  # X11
  services.xserver = {
    layout = "us";
    enable = true;
    windowManager.qtile.enable = true;
    windowManager.qtile.extraPackages = p: with p; [ qtile-extras ]; 
    displayManager.lightdm.enable = true;
  };
    
  # Laptop TLP battery saving config
  services.tlp.enable = true;
  services.tlp.settings = { };

  # Enable acpi daemon so laptop close/open is responded to
  services.acpid.enable = true;


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

  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce;[
    thunar-volman thunar-archive-plugin
  ];


  # System configuration
  system = {
    autoUpgrade = {
      enable = true;
      allowReboot = false;
      dates = "7:30";
    };
    stateVersion = "23.05"; # https://nixos.org/nixos/options.html
  };
  };
}