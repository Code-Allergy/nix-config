{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.neer.modules.app.jetbrains;
  enabled = if cfg.webstorm.enable == null then cfg.enable else cfg.webstorm.enable;
  package = if cfg.webstorm.package != null then cfg.webstorm.package else pkgs.jetbrains.webstorm;
in
{
  options.neer.modules.app.jetbrains.webstorm = {
    enable = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = "Enable WebStorm. Defaults to the root JetBrains master switch when unset.";
    };

    package = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "Package to use for WebStorm.";
    };
  };

  config = mkIf enabled {
    home.packages = [ package ];

    programs.jetbrains-remote = mkIf cfg.remote.enable {
      enable = true;
      ides = [ package ];
    };
  };
}
