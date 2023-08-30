{pkgs, ...}:

{
  imports = [
      # ../nixos/common.nix
      ../../nixos/configuration.nix
      # ../nixos/hardware-configuration.nix
  ];

  environment.systemPackages = with pkgs; [
    vim
    git
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

  # X11
  services.xserver = {
    layout = "us";
    enable = true;
    windowManager.qtile.enable = true;
    windowManager.qtile.extraPackages = p: with p; [ qtile-extras ]; 
    displayManager.lightdm.enable = true;
  };

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


  # Power Management
    
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