{
  config,
  lib,
  pkgs,
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
    services.copyq.enable = true;
    programs.pay-respects.enable = true;
    systemd.user.startServices = "sd-switch";
    services.mpris-proxy.enable = true;
  };
}
