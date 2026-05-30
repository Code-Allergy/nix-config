{
  config,
  lib,
  ...
}:

with lib;

let
  devCfg = config.global.config.development;
  cfg = devCfg.ollama;
in
{
  options.global.config.development.ollama = {
    enable = mkEnableOption "Enable Ollama" // {
      default = devCfg.enable; # Inherit enable state from main module
    };
    amdOverride = mkEnableOption "Enable AMD GPU override" // {
      default = devCfg.enable; # By default use AMD rocm for this module, maybe later we can add support for other GPUs
    };
  };

  config = mkIf cfg.enable {
    services.ollama = {
      enable = cfg.enable;
      acceleration = mkIf cfg.amdOverride "rocm";
      environmentVariables = mkIf cfg.amdOverride {
        HSA_OVERRIDE_GFX_VERSION = "11.0.0"; # 7900 XT
      };
    };

    programs.mods = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      settings = {
        default-model = "llama3.2";
        apis = {
          ollama = {
            base-url = "http://localhost:11434/api";
            models = {
              "llama3.2" = {
                max-input-chars = 650000;
              };
            };
          };
        };
      };
    };
  };
}
