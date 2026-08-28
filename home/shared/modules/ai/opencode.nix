{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.neer.modules.ai.opencode;
in

{
  options.neer.modules.ai.opencode = {
    enable = mkEnableOption "Enable OpenCode" // {
      default = config.neer.modules.dev.enable; # Inherit enable state from dev module for now
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.opencode
      pkgs.opencode-desktop
      pkgs.opencode-claude-auth
    ];
  };

}
