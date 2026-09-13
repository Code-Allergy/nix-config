{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.neer.modules.services.ai-inference;
  gateway = cfg.litellm;
  yaml = pkgs.formats.yaml {};
  networkOptions = [
    "--network=${cfg.networkName}"
    "--security-opt=no-new-privileges"
  ];
  renderBackend = backendName: backend:
    map (modelName: {
      model_name = modelName;
      litellm_params =
        {
          model = "openai/${modelName}";
          api_base = backend.apiBase;
          api_key = "os.environ/${backend.apiKeyEnvironmentVariable}";
        }
        // lib.optionalAttrs (backend.order != null) {
          inherit (backend) order;
        };
      model_info.id = "${backendName}-${modelName}";
    })
    backend.models;
  modelList = lib.concatLists (lib.mapAttrsToList renderBackend gateway.backends);
  litellmConfig = yaml.generate "litellm-config.yaml" {
    model_list = modelList;
    litellm_settings = {
      drop_params = true;
      overwrite_user_with_key_hash = true;
    };
    router_settings = {
      routing_strategy = "simple-shuffle";
      num_retries = 1;
      timeout = 600;
      allowed_fails = 2;
      cooldown_time = 60;
    };
    general_settings = {
      master_key = "os.environ/LITELLM_MASTER_KEY";
      database_url = "os.environ/DATABASE_URL";
      store_model_in_db = false;
      allow_requests_on_db_unavailable = false;
      enforce_fallback_model_access = true;
      database_connection_pool_limit = 10;
      database_connection_timeout = 60;
      database_connect_timeout = 15;
      database_socket_timeout = 300;
      database_statement_timeout = 120;
      database_lock_timeout = 15;
    };
  };
in {
  options.neer.modules.services.ai-inference.litellm = {
    enable = lib.mkEnableOption "LiteLLM authenticated API gateway";

    image = lib.mkOption {
      type = lib.types.str;
      default = "ghcr.io/berriai/litellm:v1.100.1";
      description = "Pinned LiteLLM proxy image.";
    };

    environmentFiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Runtime environment files containing LiteLLM secrets.";
    };

    backends = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          apiBase = lib.mkOption {
            type = lib.types.str;
            description = "OpenAI-compatible backend base URL.";
          };

          apiKeyEnvironmentVariable = lib.mkOption {
            type = lib.types.str;
            description = "Environment variable containing this backend's API key.";
          };

          models = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "Models routed to this backend.";
          };

          order = lib.mkOption {
            type = lib.types.nullOr lib.types.ints.positive;
            default = null;
            description = "Optional deployment priority; lower values are preferred.";
          };
        };
      });
      default = {};
      description = "Authenticated OpenAI-compatible inference backends.";
    };

    database = {
      image = lib.mkOption {
        type = lib.types.str;
        default = "docker.io/library/postgres:17";
      };

      dataDirectory = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/litellm/postgres";
      };

      environmentFiles = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Runtime environment files containing PostgreSQL initialization secrets.";
      };
    };
  };

  config = lib.mkIf (cfg.enable && gateway.enable) {
    assertions = [
      {
        assertion = gateway.backends != {};
        message = "ai-inference.litellm requires at least one backend";
      }
      {
        assertion = lib.all (backend: backend.models != []) (lib.attrValues gateway.backends);
        message = "Every ai-inference.litellm backend requires at least one model";
      }
      {
        assertion = gateway.environmentFiles != [];
        message = "ai-inference.litellm requires a secret environment file";
      }
      {
        assertion = gateway.database.environmentFiles != [];
        message = "ai-inference.litellm.database requires a secret environment file";
      }
    ];

    systemd.tmpfiles.rules = [
      "d ${gateway.database.dataDirectory} 0700 root root -"
    ];

    virtualisation.oci-containers.containers = {
      litellm-postgres = {
        image = gateway.database.image;
        autoStart = true;
        volumes = ["${gateway.database.dataDirectory}:/var/lib/postgresql/data"];
        environmentFiles = gateway.database.environmentFiles;
        extraOptions = networkOptions;
      };

      litellm = {
        image = gateway.image;
        autoStart = true;
        cmd = [
          "--config"
          "/app/config.yaml"
          "--port"
          "4000"
          "--num_workers"
          "1"
        ];
        volumes = ["${litellmConfig}:/app/config.yaml:ro"];
        environmentFiles = gateway.environmentFiles;
        environment = {
          LITELLM_MODE = "PRODUCTION";
          NO_DOCS = "True";
          NO_REDOC = "True";
          NO_OPENAPI = "True";
        };
        extraOptions = networkOptions;
      };
    };

    systemd.services = {
      podman-litellm-postgres = {
        requires = ["podman-network-ai.service"];
        after = ["podman-network-ai.service"];
      };

      podman-litellm = {
        requires = ["podman-network-ai.service"];
        wants = ["podman-litellm-postgres.service"];
        after = [
          "podman-network-ai.service"
          "podman-litellm-postgres.service"
        ];
        preStart = lib.mkAfter ''
          for attempt in {1..60}; do
            if ${config.virtualisation.podman.package}/bin/podman exec litellm-postgres pg_isready -U litellm -d litellm >/dev/null 2>&1; then
              exit 0
            fi
            ${pkgs.coreutils}/bin/sleep 1
          done

          echo "PostgreSQL did not become ready within 60 seconds" >&2
          exit 1
        '';
      };
    };
  };
}
