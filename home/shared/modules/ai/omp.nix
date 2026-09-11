{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.neer.modules.ai.omp;
in
{
  options.neer.modules.ai = {
    omp = {
      enable = mkEnableOption "Enable Oh My Pi (OMP) coding agent" // {
        default = config.neer.modules.dev.enable;
      };
    };
    oh-my-pi = {
      enable = mkEnableOption "Enable Oh My Pi (OMP) coding agent (alias for omp)" // {
        default = config.neer.modules.ai.omp.enable;
      };
    };
  };

  config = mkIf (cfg.enable || config.neer.modules.ai.oh-my-pi.enable) {
    programs.omp.enable = true;
    programs.omp.settings = {
      modelRoles.default = "openai-codex/gpt-6-astra:high";
      symbolPreset = "nerd";
      composer.shape = "box";
      theme = {
        dark = "titanium";
        light = "light";
      };
      setupVersion = 2;
      lsp = {
        enabled = true;
        formatOnWrite = true;
      };
      # MCP definitions are owned by Home Manager, not imported from OpenCode.
      enabledProviders = [ ];
    };
  };
}
