{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.neer.modules.ai.cursor;
in

{
  options.neer.modules.ai.cursor = {
    enable = mkEnableOption "Enable Cursor AI editor" // {
      default = config.neer.modules.dev.enable; # Inherit enable state from dev module for now
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.code-cursor
    ];
  };

}
