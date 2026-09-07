{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.neer.modules.ai.antigravity;
in

{
  options.neer.modules.ai.antigravity = {
    enable = mkEnableOption "Enable Google Antigravity AI editor" // {
      default = config.neer.modules.dev.enable; # Inherit enable state from dev module for now
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity
    ];
  };

}
