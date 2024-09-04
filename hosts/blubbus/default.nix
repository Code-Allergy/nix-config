{
  pkgs,
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    # Hardware config
    (modulesPath + "/installer/scan/not-detected.nix")

    # Hardware
    ../../nixos/hardware/audio.nix
    ../../nixos/hardware/bluetooth.nix
    ../../nixos/hardware/display.nix
    ../../nixos/hardware/nvidia.nix

    ../../nixos/hardware/hibernate-after-sleep.nix

    # Fileserver mounts
    ../../nixos/samba-mounts.nix

    # Register ryan as default user
    # ../../nixos/users/ryan

    # Run qtile environment
    # ../../nixos/environments/qtile.nix
    ../../nixos/environments/plasma.nix
    ../../nixos/environments/hyprland.nix
    # ../../nixos/environments/gnome.nix

    # common configs for all deployments
    # ../../nixos/common.nix
  ];

  # Bootloader.
  boot = {
    loader.systemd-boot = {
      enable = lib.mkForce false;
      editor = true;
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };

    plymouth = {
      enable = true;
      themePackages = [pkgs.catppuccin-plymouth pkgs.nixos-bgrt-plymouth];
      theme = "bgrt";
    };

    kernelParams = [
      "quiet"
      "splash"
      "acpi_backlight=nvidia_wmi_ec"

      "amd_pstate.shared_mem=1"
    ];
    initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod"];
    # initrd.kernelModules = ["dm-snapshot"];
    initrd.luks.devices = {
      root = {
        device = "/dev/disk/by-uuid/d19873f6-caa4-43a2-8032-0b6cc8e72190";
        preLVM = true;
      };
    };

    # Nvidia drivers often break on latest kernel.. use LTS instead.
    kernelPackages = pkgs.linuxPackages;
  };

  # Root FS
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/4894db5b-c287-4f21-ac36-6db9b6c8de07";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/A7A9-9D2E";
      fsType = "vfat";
    };
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/2ba14f11-3e3a-46d7-8f69-e443be36e33b";}
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  environment.systemPackages = with pkgs; [
    # power management
    powertop
    brightnessctl

    # Wifi applet
    networkmanagerapplet
  ];

  # Laptop TLP battery saving config
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = true;
  services.tlp.settings = {
    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

    CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

    PLATFORM_PROFILE_ON_AC = "balanced";
    PLATFORM_PROFILE_ON_BAT = "low-power";

    CPU_BOOST_ON_AC = "1";
    CPU_BOOST_ON_BAT = "1";

    WIFI_PWR_ON_AC = "off";
    WIFI_PWR_ON_BAT = "on";

    DISK_DEVICES = "nvme0n1 nvme1n1";

    USB_AUTOSUSPEND = "1";
    USB_ALLOWLIST = "0c45:6720 187c:0550";
  };

  # Enable acpi daemon so laptop close/open is responded to
  services.acpid.enable = true;

  # Display brightness
  programs.light.enable = true;

  # Network config
  networking = {
    hostName = "blubbus";
    networkmanager = {
      enable = true;
      wifi.powersave = true;
    };

    firewall = {
      allowedTCPPorts = [];
      allowedUDPPorts = [];
      enable = true;
    };
  };

  # services.gvfs.enable = true;
  services.fwupd.enable = true;
  services.cpupower-gui.enable = true;

  # # Udev rules for Qtile plugin
  # services.udev.extraRules = ''
  #   ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="nvidia_wmi_ec_backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
  #   ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="nvidia_wmi_ec_backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
  # '';

  # Certificates for school wlan
  # TODO broke config -- missing?
  # error: builder for '/nix/store/n7ndlgnfc8jkiqm96374aa17zf9c7rvd-nss-cacert-3.101.drv' failed with exit code 1;
  #        last 10 log lines:
  #        > Traceback (most recent call last):
  #        >   File "/nix/store/zmzk6ycn1l2fivm2syrgxiihdv7p4i6c-python3.11-buildcatrust-0.3.0/bin/.buildcatrust-wrapped", line 9, in <module>
  #        >     sys.exit(main())
  #        >              ^^^^^^
  #        >   File "/nix/store/zmzk6ycn1l2fivm2syrgxiihdv7p4i6c-python3.11-buildcatrust-0.3.0/lib/python3.11/site-packages/buildcatrust/cli.py", line 243, in main
  #        >     sys.exit(cli_main(sys.argv[1:]) or 0)
  #        >              ^^^^^^^^^^^^^^^^^^^^^^
  #        >   File "/nix/store/zmzk6ycn1l2fivm2syrgxiihdv7p4i6c-python3.11-buildcatrust-0.3.0/lib/python3.11/site-packages/buildcatrust/cli.py", line 182, in cli_main
  #        >     raise FileNotFoundError(f"Bundle not found: {bundle_path}")
  #        > FileNotFoundError: Bundle not found: /nix/store/zbzjr67bnrrhrgmbnhlism874pxc80l3-nss-cacert-3.101/etc/ssl/certs/DigiCert_Global_Root_CA.crt
  #        For full logs, run 'nix log /nix/store/n7ndlgnfc8jkiqm96374aa17zf9c7rvd-nss-cacert-3.101.drv'.
  # error: 1 dependencies of derivation '/nix/store/5y9salcw7ygw0jgrhq0hh7cww7l74izv-etc.drv' failed to build
  # error: 1 dependencies of derivation '/nix/store/dfndmqm6rl1q9gv9zz59sdxy5ysxwwbc-nixos-system-blubbus-24.05.20240830.6e99f2a.drv' failed to build
  # security.pki.certificateFiles = [
  #   "${pkgs.cacert}/etc/ssl/certs/DigiCert_Global_Root_CA.crt"
  # ];

  # Lock on lid close
  services.logind.lidSwitch = "suspend";
  # services.logind.lidSwitchExternalPower = "lock";

  # Locale & Time
  time.timeZone = "America/Regina";
  services.chrony.enable = true;
  i18n.defaultLocale = "en_CA.UTF-8";
}
