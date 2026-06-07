{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.neer.modules.system.printing;
in {
  options.neer.modules.system.printing = {
    enable = mkEnableOption "Enable printing on the system";
  };

  config = mkIf cfg.enable {
    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
