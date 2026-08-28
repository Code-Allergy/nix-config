{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.neer.modules.ai.claude;
in

{
  options.neer.modules.ai.claude = {
    enable = mkEnableOption "Enable Claude" // {
      default = config.neer.modules.dev.enable; # Inherit enable state from dev module for now
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.claude-code
      pkgs.claude-code-router
    ];
  };

}
