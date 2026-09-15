{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.neer.modules.services.ai-inference;
  modelDirectory =
    if cfg.modelCache.enable then cfg.modelCache.sourceDirectory else cfg.modelDirectory;
  yaml = pkgs.formats.yaml { };
  searxngConfig = yaml.generate "searxng-settings.yml" {
    use_default_settings = {
      engines = {
        remove = [
          "ahmia"
          "torch"
        ];
      };
    };
    general = {
      debug = false;
      instance_name = cfg.supportServices.searxngInstanceName;
    };
    search = {
      safe_search = 0;
      autocomplete = "";
      formats = [
        "html"
        "json"
      ];
    };
    server = {
      secret_key = "overridden-by-environment";
      limiter = false;
      public_instance = false;
      image_proxy = false;
    };
  };
  networkOptions = [
    "--network=${cfg.networkName}"
    "--security-opt=no-new-privileges"
  ];
in
{
  options.neer.modules.services.ai-inference.supportServices = {
    enable = lib.mkEnableOption "Open WebUI support services" // {
      default = true;
    };

    searxngInstanceName = lib.mkOption {
      type = lib.types.str;
      default = "Local Search";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.supportServices.enable) {
    neer.modules.services.ai-inference.peers = lib.mkDefault {
      kokoro = {
        proxy = "http://kokoro-tts:8880";
        models = [ "kokoro" ];
      };
      embeddings = {
        proxy = "http://qwen-embedding:8080";
        models = [ "qwen3-embedding-0.6b" ];
      };
      reranker = {
        proxy = "http://qwen-reranker:8080";
        models = [ "qwen3-reranker-0.6b" ];
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/qdrant 0750 root root -"
      "d /var/lib/searxng 0750 root root -"
      "d /var/lib/searxng/cache 0750 977 977 -"
    ];

    virtualisation.oci-containers.containers = {
      kokoro-tts = {
        image = "ghcr.io/remsky/kokoro-fastapi-cpu:v0.8.0";
        autoStart = true;
        extraOptions = networkOptions;
      };

      qwen-embedding = {
        image = "ghcr.io/ggml-org/llama.cpp:server";
        autoStart = true;
        volumes = [ "${modelDirectory}:/models:ro" ];
        cmd = [
          "-m"
          "/models/retrieval/Qwen3-Embedding-0.6B-Q8_0.gguf"
          "--host"
          "0.0.0.0"
          "--port"
          "8080"
          "--alias"
          "qwen3-embedding-0.6b"
          "--embedding"
          "--pooling"
          "last"
          "-c"
          "32768"
          "-np"
          "1"
          "-ngl"
          "0"
        ];
        extraOptions = networkOptions;
      };

      qwen-reranker = {
        image = "ghcr.io/ggml-org/llama.cpp:server";
        autoStart = true;
        volumes = [ "${modelDirectory}:/models:ro" ];
        cmd = [
          "-m"
          "/models/retrieval/qwen3-reranker-0.6b-q8_0.gguf"
          "--host"
          "0.0.0.0"
          "--port"
          "8080"
          "--alias"
          "qwen3-reranker-0.6b"
          "--embedding"
          "--reranking"
          "--pooling"
          "rank"
          "-c"
          "32768"
          "-np"
          "1"
          "-ngl"
          "0"
        ];
        extraOptions = networkOptions;
      };

      qdrant = {
        image = "docker.io/qdrant/qdrant:latest";
        autoStart = true;
        volumes = [ "/var/lib/qdrant:/qdrant/storage" ];
        extraOptions = networkOptions;
      };

      searxng = {
        image = "docker.io/searxng/searxng:latest";
        autoStart = true;
        volumes = [
          "${searxngConfig}:/etc/searxng/settings.yml:ro"
          "/var/lib/searxng/cache:/var/cache/searxng"
        ];
        environmentFiles = [ "/var/lib/searxng/searxng.env" ];
        environment = {
          SEARXNG_BIND_ADDRESS = "0.0.0.0";
          SEARXNG_PORT = "8080";
          SEARXNG_BASE_URL = "http://searxng:8080/";
          SEARXNG_LIMITER = "false";
          SEARXNG_PUBLIC_INSTANCE = "false";
          SEARXNG_IMAGE_PROXY = "false";
          FORCE_OWNERSHIP = "false";
        };
        extraOptions = networkOptions;
      };
    };

    systemd.services =
      lib.genAttrs
        [
          "podman-kokoro-tts"
          "podman-qwen-embedding"
          "podman-qwen-reranker"
          "podman-qdrant"
        ]
        (name: {
          requires = [ "podman-network-ai.service" ];
          after = [ "podman-network-ai.service" ];
          unitConfig.RequiresMountsFor = lib.optionals (lib.elem name [
            "podman-qwen-embedding"
            "podman-qwen-reranker"
          ]) [ modelDirectory ];
        })
      // {
        ai-searxng-secret = {
          description = "Create the SearXNG secret environment file";
          requiredBy = [ "podman-searxng.service" ];
          before = [ "podman-searxng.service" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            if ! test -s /var/lib/searxng/searxng.env; then
              umask 077
              printf 'SEARXNG_SECRET=' > /var/lib/searxng/searxng.env
              ${pkgs.openssl}/bin/openssl rand -hex 32 >> /var/lib/searxng/searxng.env
            fi
          '';
        };

        podman-searxng = {
          requires = [
            "podman-network-ai.service"
            "ai-searxng-secret.service"
          ];
          after = [
            "podman-network-ai.service"
            "ai-searxng-secret.service"
          ];
        };
      };
  };
}
