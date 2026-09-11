{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.neer.modules.services.ai-inference;
  searxngConfig = pkgs.writeText "searxng-settings.yml" ''
    use_default_settings: true

    general:
      debug: false
      instance_name: "Ampere Search"

    search:
      safe_search: 0
      autocomplete: ""
      formats:
        - html
        - json

    server:
      # Overridden by SEARXNG_SECRET from the container environment.
      secret_key: "overridden-by-environment"

      # This is an internal instance, so bot rate limiting is unnecessary.
      limiter: false
      public_instance: false
      image_proxy: false
  '';
  caddyConfig = pkgs.writeText "Caddyfile" ''
    {
      # Disable Caddy's admin API since we manage config declaratively.
      admin off
    }

    ${cfg.webuiHost} {
      tls /certs/fullchain.pem /certs/privkey.pem

      encode zstd gzip

      reverse_proxy open-webui:8080
    }

    ${cfg.apiHost} {
      tls /certs/fullchain.pem /certs/privkey.pem

      encode zstd gzip

      reverse_proxy llama-swap:8080
    }
  '';

  llamaSwapConfig = pkgs.writeText "llama-swap.yaml" ''
    logLevel: debug
    logToStdout: both
    healthCheckTimeout: 300
    startPort: 10001

    peers:
      kokoro:
        proxy: http://kokoro-tts:8880
        models:
          - kokoro

      embeddings:
        proxy: http://qwen-embedding:8080
        models:
          - qwen3-embedding-0.6b

      reranker:
        proxy: http://qwen-reranker:8080
        models:
          - qwen3-reranker-0.6b

    models:
      # -------------------------------------------------------------------------
      # Ling 3.0 Tiny
      # -------------------------------------------------------------------------

      ling-3.0-tiny-128k:
        name: "Ling 3.0 Tiny"
        description: "Ling 3.0 Tiny - native 128K context"
        ttl: 600
        cmd: |
          llama-server \
            --host 127.0.0.1 \
            --port ''${PORT} \
            -m /models/Ling-3.0-tiny-Q4_0.gguf \
            -ngl 999 \
            -fa on \
            -ctk f16 \
            -ctv f16 \
            -ub 256 \
            -c 131072 \
            -np 1

      ling-3.0-tiny-256k:
        name: "Ling 3.0 Tiny XL"
        description: "Ling 3.0 Tiny - 256K YaRN context"
        ttl: 600
        cmd: |
          llama-server \
            --host 127.0.0.1 \
            --port ''${PORT} \
            -m /models/Ling-3.0-tiny-Q4_0.gguf \
            -ngl 999 \
            -fa on \
            -ctk f16 \
            -ctv f16 \
            -ub 256 \
            -c 262144 \
            --rope-scaling yarn \
            --rope-scale 2 \
            --rope-freq-base 6000000 \
            --yarn-orig-ctx 131072 \
            -np 1

      # -------------------------------------------------------------------------
      # Spark X2.5 4B
      # -------------------------------------------------------------------------

      # Fast interactive profile.
      #
      # Measured Q4_K_M performance:
      #   fresh: ~142 t/s
      #   8K:    ~129 t/s
      #   16K:   ~105-115 t/s
      spark-2.5-light:
        name: "Spark X2.5 4B Light"
        description: "Spark X2.5 4B Q4_K_M - fast 16K context"
        ttl: 600
        cmd: |
          llama-server \
            --host 127.0.0.1 \
            --port ''${PORT} \
            -m /models/Spark-X2.5-4B-Q4_K_M.gguf \
            -ngl 999 \
            -fa on \
            -ctk f16 \
            -ctv f16 \
            -ub 256 \
            -c 16384 \
            -np 1

      # Default balanced Spark profile.
      #
      # Measured:
      #   fresh: ~142 t/s
      #   8K:    ~129 t/s
      #   32K:   ~104 t/s
      #   64K:    ~83 t/s
      spark-2.5-normal:
        name: "Spark X2.5 4B"
        description: "Spark X2.5 4B Q4_K_M - balanced 64K context"
        ttl: 600
        cmd: |
          llama-server \
            --host 127.0.0.1 \
            --port ''${PORT} \
            -m /models/Spark-X2.5-4B-Q4_K_M.gguf \
            -ngl 999 \
            -fa on \
            -ctk f16 \
            -ctv f16 \
            -ub 256 \
            -c 65536 \
            -np 1

      # Highest weight fidelity.
      #
      # Measured:
      #   fresh: ~98 t/s
      #   8K:    ~92 t/s
      #   32K:   ~79 t/s
      #   64K:   ~66 t/s
      spark-2.5-quality:
        name: "Spark X2.5 4B Quality"
        description: "Spark X2.5 4B Q8_0 - quality-first 64K context"
        ttl: 600
        cmd: |
          llama-server \
            --host 127.0.0.1 \
            --port ''${PORT} \
            -m /models/Spark-X2.5-4B-Q8_0.gguf \
            -ngl 999 \
            -fa on \
            -ctk f16 \
            -ctv f16 \
            -ub 256 \
            -c 65536 \
            -np 1

      # Maximum-context Spark profile.
      #
      # Q4 KV is intentionally used here for capacity rather than speed.
      spark-2.5-xl:
        name: "Spark X2.5 4B XL"
        description: "Spark X2.5 4B Q4_K_M - 320K context"
        ttl: 600
        cmd: |
          llama-server \
            --host 127.0.0.1 \
            --port ''${PORT} \
            -m /models/Spark-X2.5-4B-Q4_K_M.gguf \
            -ngl 999 \
            -fa on \
            -ctk q4_0 \
            -ctv q4_0 \
            -b 512 \
            -ub 64 \
            -c 327680 \
            -np 1

      qwen-3.5-9b-smart:
        name: "Qwen 3.5 9B Smart"
        description: "Qwen 3.5 9B Q5_K_M - maximum intelligence, 40K context"
        ttl: 600
        cmd: |
          llama-server \
            --host 127.0.0.1 \
            --port ''${PORT} \
            -m /models/Qwen3.5-9B-Q5_K_M.gguf \
            -ngl 999 \
            -fa on \
            -ctk f16 \
            -ctv f16 \
            -ub 128 \
            -c 40960 \
            -np 1 \
            --jinja

      qwen-3.5-9b-smart-uncensored:
        name: "Qwen 3.5 9B Smart (uncensored)"
        description: "Qwen 3.5 9B Q4_K_M - maximum intelligence, 40K context, uncensored"
        ttl: 600
        cmd: |
          llama-server \
            --host 127.0.0.1 \
            --port ''${PORT} \
            -m /models/Qwen3.5-9B-Uncensored-Q4_K_M.gguf \
            -ngl 999 \
            -fa on \
            -ctk f16 \
            -ctv f16 \
            -ub 128 \
            -c 40960 \
            -np 1 \
            --jinja

      qwen-3.5-9b-vision:
        name: "Qwen 3.5 9B Vision"
        description: "Qwen 3.5 9B Q4_K_M + Q8 vision projector - 8K context"
        ttl: 600
        cmd: |
          llama-server \
            --host 127.0.0.1 \
            --port ''${PORT} \
            -m /models/Qwen3.5-9B-Q4_K_M.gguf \
            --mmproj /models/Qwen3.5-9B-mmproj-F16.gguf \
            -ngl 999 \
            -fa on \
            -ctk f16 \
            -ctv f16 \
            -ub 128 \
            -c 8192 \
            -np 1 \
            --jinja


      qwen-3.5-9b-vision-uncensored:
        name: "Qwen 3.5 9B Vision (uncensored)"
        description: "Qwen 3.5 9B Q4_K_M + Q8 vision projector - 8K context (uncensored)"
        ttl: 600
        cmd: |
          llama-server \
            --host 127.0.0.1 \
            --port ''${PORT} \
            -m /models/Qwen3.5-9B-Uncensored-Q4_K_M.gguf \
            --mmproj /models/Qwen3.5-9B-mmproj-F16.gguf \
            -ngl 999 \
            -fa on \
            -ctk f16 \
            -ctv f16 \
            -ub 128 \
            -c 8192 \
            -np 1 \
            --jinja

      whisper-large-v3-turbo:
        name: "Whisper Large V3 Turbo"
        description: "GPU accelerated speech-to-text"
        ttl: 300
        checkEndpoint: /
        cmd: |
          whisper-server \
            --host 127.0.0.1 \
            --port ''${PORT} \
            -m /models/ggml-large-v3-turbo-q8_0.bin \
            --language auto \
            --convert \
            --tmp-dir /tmp \
            --inference-path /v1/audio/transcriptions

      flux2-klein-4b:
        name: "FLUX.2 Klein 4B"
        description: "FLUX.2 Klein 4B with uncensored Qwen text encoder"
        ttl: 300
        checkEndpoint: /v1/models
        cmd: |
          sd-server \
            --listen-ip 127.0.0.1 \
            --listen-port ''${PORT} \
            --diffusion-model /models/image/flux-2-klein-4b-Q4_K_M.gguf \
            --llm /models/image/flux2-klein-4b-uncensored-q4_k_m.gguf \
            --vae /models/image/ae.safetensors \
            --cfg-scale 1.0 \
            --steps 4 \
            --diffusion-fa \
            --offload-to-cpu

    profiles:
      # Ling profiles
      ling-normal:
        description: "Ling - fast general inference with native 128K context"
        pins:
          chat: ling-3.0-tiny-128k

      ling-xl:
        description: "Ling - extended 256K context"
        pins:
          chat: ling-3.0-tiny-256k

      # Spark profiles
      spark-light:
        description: "Spark - maximum interactive speed, 16K context"
        pins:
          chat: spark-2.5-light

      spark-normal:
        description: "Spark - balanced Q4_K_M profile, 64K context"
        pins:
          chat: spark-2.5-normal

      spark-quality:
        description: "Spark - Q8_0 quality-first profile, 64K context"
        pins:
          chat: spark-2.5-quality

      spark-xl:
        description: "Spark - maximum-context 320K profile"
        pins:
          chat: spark-2.5-xl

      qwen-smart:
        description: "Qwen 3.5 9B - highest intelligence local profile"
        pins:
          chat: qwen-3.5-9b-smart

      qwen-smart-uncensored:
        description: "Qwen 3.5 9B - highest intelligence local profile (uncensored)"
        pins:
          chat: qwen-3.5-9b-smart-uncensored

      qwen-vision:
        description: "Qwen 3.5 9B - multimodal image and text reasoning"
        pins:
          chat: qwen-3.5-9b-vision

      qwen-vision-uncensored:
        description: "Qwen 3.5 9B - multimodal image and text reasoning (uncensored)"
        pins:
          chat: qwen-3.5-9b-vision-uncensored

    hooks:
      on_startup:
        profile: spark-normal
  '';
in
{
  options.neer.modules.services.ai-inference = {
    enable = lib.mkEnableOption "AI inference services";

    webuiHost = lib.mkOption {
      type = lib.types.str;
      description = "Public hostname for Open WebUI";
      example = "ai.example.com";
    };

    apiHost = lib.mkOption {
      type = lib.types.str;
      description = "Public hostname for the llama-swap OpenAI API";
      example = "llm.example.com";
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.tmpfiles.rules = [
      "d /var/lib/open-webui 0750 root root -"
      "d /var/lib/llama.cpp 0750 root root -"
      "d /var/lib/llama.cpp/models 0750 root root -"

      "d /var/lib/qdrant 0750 root root -"

      "d /var/lib/searxng 0750 root root -"
      "d /var/lib/searxng/cache 0750 977 977 -"

      # certsync needs execute/traverse permission through this parent,
      # but not write permission to the parent itself.
      "d /var/lib/caddy 0750 root cert-deploy -"

      "d /var/lib/caddy/data 0750 root root -"
      "d /var/lib/caddy/config 0750 root root -"

      # OPNsense writes here.
      "d /var/lib/caddy/certs 0750 certsync cert-deploy -"
    ];

    systemd.services.podman-network-ai = {
      description = "Create AI Podman network";

      wantedBy = [ "multi-user.target" ];
      before = [
        "podman-llama-swap.service"
        "podman-open-webui.service"
        "podman-searxng.service"
        "podman-caddy.service"
      ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        ${config.virtualisation.podman.package}/bin/podman network inspect ai >/dev/null 2>&1 \
          || ${config.virtualisation.podman.package}/bin/podman network create ai
      '';
    };

    virtualisation.oci-containers = {
      backend = "podman";
      containers = {
        llama-swap = {
          image = "ghcr.io/mostlygeek/llama-swap:unified-cuda";
          autoStart = true;

          volumes = [
            "/var/lib/llama.cpp/models:/models:ro"
            "${llamaSwapConfig}:/etc/llama-swap/config/config.yaml:ro"
          ];

          extraOptions = [
            "--network=ai"
            "--device=nvidia.com/gpu=all"
          ];
        };

        open-webui = {
          image = "ghcr.io/open-webui/open-webui:main";
          autoStart = true;

          volumes = [
            "/var/lib/open-webui:/app/backend/data"
          ];

          environment = {
            # ---------------------------------------------------------------------------
            # Chat
            # ---------------------------------------------------------------------------

            ENABLE_OLLAMA_API = "false";

            ENABLE_OPENAI_API = "true";
            OPENAI_API_BASE_URL = "http://llama-swap:8080/v1";
            OPENAI_API_KEY = "none";

            # ---------------------------------------------------------------------------
            # Speech-to-text
            # ---------------------------------------------------------------------------

            AUDIO_STT_ENGINE = "openai";
            AUDIO_STT_OPENAI_API_BASE_URL = "http://llama-swap:8080/v1";
            AUDIO_STT_OPENAI_API_KEY = "none";
            AUDIO_STT_MODEL = "whisper-large-v3-turbo";

            # ---------------------------------------------------------------------------
            # Text-to-speech
            # ---------------------------------------------------------------------------

            AUDIO_TTS_ENGINE = "openai";
            AUDIO_TTS_OPENAI_API_BASE_URL = "http://llama-swap:8080/v1";
            AUDIO_TTS_OPENAI_API_KEY = "none";
            AUDIO_TTS_MODEL = "kokoro";
            AUDIO_TTS_VOICE = "af_bella";

            # ---------------------------------------------------------------------------
            # Images
            # ---------------------------------------------------------------------------

            ENABLE_IMAGE_GENERATION = "true";
            IMAGE_GENERATION_ENGINE = "openai";
            IMAGES_OPENAI_API_BASE_URL = "http://llama-swap:8080/v1";
            IMAGES_OPENAI_API_KEY = "none";
            IMAGE_GENERATION_MODEL = "flux2-klein-4b";

            # ---------------------------------------------------------------------------
            # Web Search
            # ---------------------------------------------------------------------------

            ENABLE_WEB_SEARCH = "true";
            WEB_SEARCH_ENGINE = "searxng";

            SEARXNG_QUERY_URL = "http://searxng:8080/search?q=<query>";

            WEB_SEARCH_RESULT_COUNT = "5";
            WEB_SEARCH_CONCURRENT_REQUESTS = "5";

            # ---------------------------------------------------------------------------
            # Vector DB
            # ---------------------------------------------------------------------------
            VECTOR_DB = "qdrant";
            QDRANT_URI = "http://qdrant:6333";

            ENABLE_QDRANT_MULTITENANCY_MODE = "true";
            QDRANT_COLLECTION_PREFIX = "open-webui";

            # Optional initially, REST enabled for now for simplicity
            QDRANT_PREFER_GRPC = "false";
            QDRANT_TIMEOUT = "10";

            # ---------------------------------------------------------------------------
            # RAG / Embeddings
            # ---------------------------------------------------------------------------

            RAG_EMBEDDING_ENGINE = "openai";
            RAG_OPENAI_API_BASE_URL = "http://llama-swap:8080/v1";
            RAG_OPENAI_API_KEY = "none";
            RAG_EMBEDDING_MODEL = "qwen3-embedding-0.6b";

            # ---------------------------------------------------------------------------
            # RAG / Reranking
            # ---------------------------------------------------------------------------

            RAG_RERANKING_ENGINE = "external";
            RAG_EXTERNAL_RERANKER_URL = "http://llama-swap:8080/v1/rerank";
            RAG_EXTERNAL_RERANKER_API_KEY = "none";
            RAG_RERANKING_MODEL = "qwen3-reranker-0.6b";
            RAG_TOP_K_RERANKER = "5";

            ENABLE_RAG_HYBRID_SEARCH = "true";

            # Retrieve more than we ultimately feed the model, because the reranker will
            # reduce this candidate set.
            RAG_TOP_K = "15";

            ENABLE_PERSISTENT_CONFIG = "false";

            WEBUI_URL = "https://${cfg.webuiHost}";
            CORS_ALLOW_ORIGIN = "https://${cfg.webuiHost}";
            WEBUI_SESSION_COOKIE_SECURE = "true";
          };

          extraOptions = [
            "--network=ai"
            "--security-opt=no-new-privileges"
          ];
        };

        kokoro-tts = {
          image = "ghcr.io/remsky/kokoro-fastapi-cpu:v0.8.0";
          autoStart = true;

          extraOptions = [
            "--network=ai"
            "--security-opt=no-new-privileges"
          ];
        };

        qwen-embedding = {
          image = "ghcr.io/ggml-org/llama.cpp:server";
          autoStart = true;

          volumes = [
            "/var/lib/llama.cpp/models:/models:ro"
          ];

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

          extraOptions = [
            "--network=ai"
            "--security-opt=no-new-privileges"
          ];
        };

        qwen-reranker = {
          image = "ghcr.io/ggml-org/llama.cpp:server";
          autoStart = true;

          volumes = [
            "/var/lib/llama.cpp/models:/models:ro"
          ];

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

          extraOptions = [
            "--network=ai"
            "--security-opt=no-new-privileges"
          ];
        };

        qdrant = {
          image = "docker.io/qdrant/qdrant:latest";
          autoStart = true;

          volumes = [
            "/var/lib/qdrant:/qdrant/storage"
          ];

          extraOptions = [
            "--network=ai"
            "--security-opt=no-new-privileges"
          ];
        };

        searxng = {
          image = "docker.io/searxng/searxng:latest";
          autoStart = true;

          volumes = [
            "${searxngConfig}:/etc/searxng/settings.yml:ro"
            "/var/lib/searxng/cache:/var/cache/searxng"
          ];

          environmentFiles = [
            "/var/lib/searxng/searxng.env"
          ];

          environment = {
            SEARXNG_BIND_ADDRESS = "0.0.0.0";
            SEARXNG_PORT = "8080";
            SEARXNG_BASE_URL = "http://searxng:8080/";

            SEARXNG_LIMITER = "false";
            SEARXNG_PUBLIC_INSTANCE = "false";
            SEARXNG_IMAGE_PROXY = "false";

            # Do not let the container attempt to chown the read-only Nix config.
            FORCE_OWNERSHIP = "false";
          };

          extraOptions = [
            "--network=ai"
            "--security-opt=no-new-privileges"
          ];
        };

        caddy = {
          image = "docker.io/library/caddy:2";
          autoStart = true;

          ports = [
            "80:80"
            "443:443"
            "443:443/udp"
          ];

          volumes = [
            "${caddyConfig}:/etc/caddy/Caddyfile:ro"

            "/var/lib/caddy/certs/fullchain.pem:/certs/fullchain.pem:ro"
            "/var/lib/caddy/certs/privkey.pem:/certs/privkey.pem:ro"

            "/var/lib/caddy/data:/data"
            "/var/lib/caddy/config:/config"
          ];

          extraOptions = [
            "--network=ai"
            "--security-opt=no-new-privileges"
          ];
        };

      };
    };

    systemd.services.podman-open-webui = {
      requires = [ "podman-network-ai.service" ];
      after = [
        "podman-network-ai.service"
        "podman-llama-swap.service"
      ];
    };

    systemd.services.podman-llama-swap = {
      requires = [ "podman-network-ai.service" ];
      after = [
        "podman-network-ai.service"
        "nvidia-container-toolkit-cdi-generator.service"
      ];
    };

    systemd.services.podman-caddy = {
      requires = [ "podman-network-ai.service" ];
      after = [
        "podman-network-ai.service"
      ];
    };

    systemd.services.podman-searxng = {
      requires = [ "podman-network-ai.service" ];

      after = [
        "podman-network-ai.service"
      ];
    };

  };
}
