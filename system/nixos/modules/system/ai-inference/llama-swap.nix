{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.neer.modules.services.ai-inference;
  cache = cfg.modelCache;
  cacheMaxBytes = cache.maxSizeGiB * 1024 * 1024 * 1024;
  renderModel = _: model: let
    cacheFiles = model.cacheFiles or [];
    llamaSwapModel = builtins.removeAttrs model ["cacheFiles"];
  in
    llamaSwapModel
    // lib.optionalAttrs (cache.enable && cacheFiles != []) {
      env = (model.env or []) ++ ["MODEL_CACHE_MAX_BYTES=${toString cacheMaxBytes}"];
      cmd = "/bin/sh /etc/llama-swap/cache-model ${lib.escapeShellArgs cacheFiles} -- ${model.cmd}";
    };
  renderedModels = lib.mapAttrs renderModel cfg.models;
  modelVolumes =
    if cache.enable
    then [
      "${cache.directory}:/models"
      "${cache.sourceDirectory}:/model-catalog:ro"
      "${./model-cache.sh}:/etc/llama-swap/cache-model:ro"
    ]
    else ["${cfg.modelDirectory}:/models:ro"];
  yaml = pkgs.formats.yaml {};
  llamaSwapConfig = yaml.generate "llama-swap.yaml" (
    cfg.extraConfig
    // {
      logLevel = cfg.llamaSwap.logLevel;
      logToStdout = "both";
      healthCheckTimeout = cfg.llamaSwap.healthCheckTimeout;
      startPort = cfg.llamaSwap.startPort;
      models = renderedModels;
      inherit (cfg) peers profiles;
    }
    // lib.optionalAttrs (cfg.startupProfile != null) {
      hooks.on_startup.profile = cfg.startupProfile;
    }
  );
in {
  options.neer.modules.services.ai-inference.llamaSwap = {
    image = lib.mkOption {
      type = lib.types.str;
      default = "ghcr.io/mostlygeek/llama-swap:unified-vulkan";
      description = "llama-swap container image appropriate for this host's accelerator.";
    };

    devices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Host devices made available to the llama-swap container.";
    };

    extraOptions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional Podman options, such as CDI GPU mappings.";
    };

    serviceAfter = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional systemd units that must start before llama-swap.";
    };

    bindAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host address used when publishing the llama-swap API.";
    };

    port = lib.mkOption {
      type = lib.types.nullOr lib.types.port;
      default = null;
      description = "Optional host port for the llama-swap API; null leaves it container-only.";
    };

    logLevel = lib.mkOption {
      type = lib.types.enum [
        "debug"
        "info"
        "warn"
        "error"
      ];
      default = "debug";
    };

    healthCheckTimeout = lib.mkOption {
      type = lib.types.ints.positive;
      default = 300;
    };

    startPort = lib.mkOption {
      type = lib.types.port;
      default = 10001;
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.llama-swap = {
      image = cfg.llamaSwap.image;
      autoStart = true;

      volumes = modelVolumes ++ ["${llamaSwapConfig}:/etc/llama-swap/config/config.yaml:ro"];

      devices = cfg.llamaSwap.devices;
      ports = lib.optional (cfg.llamaSwap.port != null) "${cfg.llamaSwap.bindAddress}:${toString cfg.llamaSwap.port}:8080";

      extraOptions =
        [
          "--network=${cfg.networkName}"
          "--security-opt=no-new-privileges"
        ]
        ++ cfg.llamaSwap.extraOptions;
    };

    systemd.services.podman-llama-swap = {
      requires = ["podman-network-ai.service"];
      after = ["podman-network-ai.service"] ++ cfg.llamaSwap.serviceAfter;
      unitConfig.RequiresMountsFor = lib.optionals cache.enable [
        cache.sourceDirectory
        cache.directory
      ];
    };
  };
}
