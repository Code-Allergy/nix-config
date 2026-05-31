{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.neer.modules.app.discord;
in
{
  options.neer.modules.app.discord = {
    enable = mkEnableOption "Enable Discord";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      vesktop
    ];

    # Discord arRPC
    services.arrpc.enable = true;
  };

}
