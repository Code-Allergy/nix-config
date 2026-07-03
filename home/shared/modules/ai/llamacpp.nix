{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.neer.modules.ai.llamacpp;
in

{
  options.neer.modules.ai.llamacpp = {
    enable = mkEnableOption "Enable Llama.cpp" // {
      default = config.neer.modules.dev.enable; # Inherit enable state from dev module for now
    };
    amdOverride = mkEnableOption "Enable AMD GPU override" // {
      default = config.neer.modules.dev.enable; # By default use AMD rocm for this module
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.llama-cpp-rocm
      pkgs.mcp-nixos
    ];
  };

}
