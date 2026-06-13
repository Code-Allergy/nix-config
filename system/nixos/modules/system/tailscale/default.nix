{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.neer.modules.system.tailscale;
in {
  options.neer.modules.system.tailscale = {
    enable = mkEnableOption "Enable tailscale on the system";
  };

  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "client";

      extraUpFlags = [
        "--accept-routes"
        "--accept-dns"
      ];
    };
  };
}
