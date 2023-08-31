{pkgs, config, lib, modulesPath, ...}:

{
  imports = [
    # Hardware config
    (modulesPath + "/profiles/qemu-guest.nix")

    # Hardware
    ../../nixos/audio.nix
    ../../nixos/bluetooth.nix

    # Fileserver mounts
    ../../nixos/samba-mounts.nix

    # Register ryan as default user
    ../../nixos/users/ryan

    # common configs for all deployments
    ../../nixos/common.nix
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
    initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" =
      { device = "/dev/disk/by-label/NIXROOT";
        fsType = "ext4";
      };

    "/boot" =
      { device = "/dev/disk/by-label/NIXBOOT";
        fsType = "vfat";
      };
  };
  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  environment.systemPackages = with pkgs; [
    # power management
    powertop
  ];

  # X11
  services.xserver = {
    enable = true;
    layout = "us";
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

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Locale & Time
  time.timeZone = "America/Regina";
  services.chrony.enable = true;
  i18n.defaultLocale = "en_CA.UTF-8";
}