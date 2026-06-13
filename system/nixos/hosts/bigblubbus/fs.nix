{lib, ...}: {
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/5639e7ce-bcb2-4481-8c59-6a537f221076";
      fsType = "ext4";
      options = ["defaults" "relatime" "discard"];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/3850-28A6";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
    "/media/ssd0" = {
      device = "/dev/disk/by-uuid/b3cb05da-a6e5-4c73-9251-0e42daf1285e";
      fsType = "ext4";
      options = ["defaults" "relatime" "discard"];
    };
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/a3e4489e-9ad2-4ada-b00a-17e94ea0a518";
      priority = 10;
    }
  ];

  # Enable TRIM for SSDs
  services.fstrim.enable = lib.mkDefault true;
  systemd.timers.fstrim.timerConfig = {
    OnCalendar = "weekly";
  };
}
