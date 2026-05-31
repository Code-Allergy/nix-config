{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.neer.modules.app.kdeconnect;
in
{
  options.neer.modules.app.kdeconnect = {
    enable = mkEnableOption "Enable KDE Connect";
  };

  config = mkIf cfg.enable {
    services.kdeconnect = {
      enable = true;
      package = pkgs.kdePackages.kdeconnect-kde;
      indicator = true;
    };
  };
}
