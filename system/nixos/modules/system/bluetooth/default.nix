{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.neer.modules.system.bluetooth;
in
{
  options.neer.modules.system.bluetooth = {
    enable = mkEnableOption "Bluetooth Settings";
    powerOnBoot = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      package = pkgs.bluez;
      powerOnBoot = cfg.powerOnBoot;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };

    services.blueman.enable = true;
    hardware.enableAllFirmware = true;
  };
}
