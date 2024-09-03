{
  pkgs,
  lib,
  config,
  ...
}: {
  # Nvidia GPU
  # Only configured statically for blubbus ONLY
  hardware.opengl = {
    enable = true;
    # driSupport = true;
    # driSupport32Bit = true;
    # extraPackages = with pkgs; [
    #   vaapiVdpau
    #   libvdpau-va-gl
    # ];
  };

  # Nvidia
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;

    # Open source driver
    open = false;

    # nvidia-settings menu
    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      amdgpuBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # environment.systemPackages = with pkgs; [
  #   # nvidia-offload
  #   pciutils
  #   glxinfo
  # ];
}
