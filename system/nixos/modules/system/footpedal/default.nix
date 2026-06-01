{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.neer.modules.system.footpedal;
in
{
  options.neer.modules.system.footpedal = {
    enable = mkEnableOption "Enable footpetal udev";
  };

  config = mkIf cfg.enable {
    services.udev.extraHwdb = ''
      evdev:input:b*v05F3p00FF*
        KEYBOARD_KEY_90001=f14
        KEYBOARD_KEY_90002=f15
        KEYBOARD_KEY_90003=f16
    '';
  };
}
