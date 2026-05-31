{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.neer.modules.system.nvidia;
in
{
  options.neer.modules.system.nvidia = {
    enable = mkEnableOption "nvidia gpu hardware";
  };

  config = mkIf cfg.enable {
    # Nvidia GPU for blubbus ONLY
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Nvidia
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = true;

      # Open source driver
      open = true;

      # nvidia-settings menu
      nvidiaSettings = true;

      package = config.boot.kernelPackages.nvidiaPackages.latest;

      # TODO: This can have an additional flag, not sure if it's a problem on non laptops (dont have one to test!)
      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;
        amdgpuBusId = "PCI:6:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };
}
