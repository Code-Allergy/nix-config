{
  config,
  lib,
  ...
}: let
  cfg = config.neer.modules.services.ai-inference;
  inherit (lib) mkEnableOption mkIf mkOption types;
in {
  imports = [
    ./model-cache.nix
    ./llama-swap.nix
    ./open-webui.nix
    ./support-services.nix
    ./reverse-proxy.nix
  ];

  options.neer.modules.services.ai-inference = {
    enable = mkEnableOption "AI inference services";

    networkName = mkOption {
      type = types.str;
      default = "ai";
      description = "Podman network shared by the AI inference containers.";
    };

    modelDirectory = mkOption {
      type = types.str;
      default = "/var/lib/llama.cpp/models";
      description = "Direct model directory used when the on-demand model cache is disabled.";
    };

    models = mkOption {
      type = types.attrsOf types.attrs;
      default = {};
      description = "llama-swap model definitions, keyed by model ID.";
      example = lib.literalExpression ''
        {
          local-model = {
            name = "Local model";
            cacheFiles = [ "model.gguf" ];
            ttl = 600;
            cmd = "llama-server --port ''${PORT} -m /models/model.gguf";
          };
        }
      '';
    };

    profiles = mkOption {
      type = types.attrsOf types.attrs;
      default = {};
      description = "llama-swap profile definitions, keyed by profile ID.";
    };

    peers = mkOption {
      type = types.attrsOf types.attrs;
      default = {};
      description = "Existing OpenAI-compatible services proxied by llama-swap.";
    };

    startupProfile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Optional llama-swap profile to activate on startup.";
    };

    extraConfig = mkOption {
      type = types.attrs;
      default = {};
      description = "Additional top-level llama-swap YAML configuration.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.models != {} || cfg.peers != {};
        message = "ai-inference requires at least one model or peer";
      }
      {
        assertion = cfg.startupProfile == null || builtins.hasAttr cfg.startupProfile cfg.profiles;
        message = "ai-inference.startupProfile must name a configured profile";
      }
    ];

    systemd.tmpfiles.rules = lib.optional (!cfg.modelCache.enable) "d ${cfg.modelDirectory} 0750 root root -";

    systemd.services.podman-network-ai = {
      description = "Create the AI inference Podman network";
      wantedBy = ["multi-user.target"];
      before = [
        "podman-llama-swap.service"
        "podman-open-webui.service"
        "podman-kokoro-tts.service"
        "podman-qwen-embedding.service"
        "podman-qwen-reranker.service"
        "podman-qdrant.service"
        "podman-searxng.service"
        "podman-ai-reverse-proxy.service"
      ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        ${config.virtualisation.podman.package}/bin/podman network inspect ${lib.escapeShellArg cfg.networkName} >/dev/null 2>&1 \
          || ${config.virtualisation.podman.package}/bin/podman network create ${lib.escapeShellArg cfg.networkName}
      '';
    };

    virtualisation.oci-containers.backend = "podman";
  };
}
