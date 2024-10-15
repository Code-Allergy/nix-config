{
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
}
