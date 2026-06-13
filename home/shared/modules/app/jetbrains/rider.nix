{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.neer.modules.app.jetbrains;
  enabled =
    if cfg.rider.enable == null
    then cfg.enable
    else cfg.rider.enable;
  package =
    if cfg.rider.package != null
    then cfg.rider.package
    else pkgs.jetbrains.rider;
in {
  options.neer.modules.app.jetbrains.rider = {
    enable = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = "Enable Rider. Defaults to the root JetBrains master switch when unset.";
    };

    package = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "Package to use for Rider.";
    };
  };

  config = mkIf enabled {
    home.packages = [package];

    programs.jetbrains-remote = mkIf cfg.remote.enable {
      enable = true;
      ides = [package];
    };
  };
}
