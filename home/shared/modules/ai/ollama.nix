{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.neer.modules.ai.ollama;
in {
  options.neer.modules.ai.ollama = {
    enable =
      mkEnableOption "Enable Ollama"
      // {
        default = config.neer.modules.dev.enable; # Inherit enable state from dev module for now
      };
    amdOverride =
      mkEnableOption "Enable AMD GPU override"
      // {
        default = config.neer.modules.dev.enable; # By default use AMD rocm for this module
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
