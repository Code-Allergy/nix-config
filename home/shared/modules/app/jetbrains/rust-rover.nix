{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.neer.modules.app.jetbrains;
  enabled = if cfg.rustRover.enable == null then cfg.enable else cfg.rustRover.enable;
  package = if cfg.rustRover.package != null then cfg.rustRover.package else pkgs.jetbrains.rust-rover;
in
{
  options.neer.modules.app.jetbrains.rustRover = {
    enable = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = "Enable Rust Rover. Defaults to the root JetBrains master switch when unset.";
    };

    package = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "Package to use for Rust Rover.";
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
