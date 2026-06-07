{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.neer.profiles.work;
in {
  options.neer.profiles.work = {
    enable = mkEnableOption "work profile";
  };

  config = mkIf cfg.enable {
    environment.variables = {
      IS_WORK = "Y";
    };
  };
}
