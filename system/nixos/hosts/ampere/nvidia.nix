{ pkgs, config, ... }:
{
  # This selects the NVIDIA driver; it does not enable a desktop.
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics.enable = true;

  hardware.nvidia = {
    # The RTX 3070 supports NVIDIA's open kernel modules.
    open = true;

    modesetting.enable = true;
    nvidiaSettings = false;

    # Keep desktop/laptop power-management features out of this setup.
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  environment.systemPackages = [
    pkgs.pciutils
  ];

}
