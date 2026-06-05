{
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.neer.modules.app.utility;
in
{
  options.neer.modules.app.utility = {
    enable = mkEnableOption "Enable utility apps" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    services.copyq.enable = true; # Clipboard manager
    systemd.user.startServices = "sd-switch";
    services.mpris-proxy.enable = true;
  };
}
