{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.neer.modules.ai.codex;
in

{
  options.neer.modules.ai.codex = {
    enable = mkEnableOption "Enable Codex" // {
      default = config.neer.modules.dev.enable; # Inherit enable state from dev module for now
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.codex
    ];
  };

}
