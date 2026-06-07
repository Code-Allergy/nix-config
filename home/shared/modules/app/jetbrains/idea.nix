{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.neer.modules.app.jetbrains;
  enabled = if cfg.idea.enable == null then cfg.enable else cfg.idea.enable;
  package = if cfg.idea.package != null then cfg.idea.package else pkgs.jetbrains.idea;
in
{
  options.neer.modules.app.jetbrains.idea = {
    enable = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = "Enable IntelliJ IDEA. Defaults to the root JetBrains master switch when unset.";
    };

    package = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "Package to use for IntelliJ IDEA.";
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
