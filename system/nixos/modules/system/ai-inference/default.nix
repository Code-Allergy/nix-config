{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.neer.modules.services.ai-inference;
  llamaSwapConfig = pkgs.writeText "llama-swap.yaml" ''
    healthCheckTimeout: 300
    startPort: 10001

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
      # This is experimental until 512K is validated on the 8 GB 3070.
      spark-2.5-xl:
        name: "Spark X2.5 4B XL"
        description: "Spark X2.5 4B Q4_K_M - 512K context"
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
            -ub 128 \
            -c 524288 \
            -np 1

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
        description: "Spark - maximum-context 512K profile"
        pins:
          chat: spark-2.5-xl

    hooks:
      on_startup:
        profile: spark-normal
  '';
in
{
  options.neer.modules.services.ai-inference = {
    enable = lib.mkEnableOption "AI inference services";

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.tmpfiles.rules = [
      "d /var/lib/ollama 0750 root root -"
      "d /var/lib/open-webui 0750 root root -"
      "d /var/lib/llama.cpp 0750 root root -"
      "d /var/lib/llama.cpp/models 0750 root root -"
      "d /var/lib/caddy 0750 root root -"
      "d /var/lib/caddy/data 0750 root root -"
      "d /var/lib/caddy/config 0750 root root -"
    ];

    systemd.services.podman-network-ai = {
      description = "Create AI Podman network";

      wantedBy = [ "multi-user.target" ];
      before = [
        "podman-ollama.service"
        "podman-open-webui.service"
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

          ports = [
            "9292:8080"
          ];

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

          ports = [
            "3000:8080"
          ];

          volumes = [
            "/var/lib/open-webui:/app/backend/data"
          ];

          environment = {
            ENABLE_OLLAMA_API = "false";

            ENABLE_OPENAI_API = "true";
            OPENAI_API_BASE_URL = "http://llama-swap:8080/v1";
            OPENAI_API_KEY = "none";
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
            "/var/lib/caddy/Caddyfile:/etc/caddy/Caddyfile:ro"
            "/var/lib/caddy/data:/data"
            "/var/lib/caddy/config:/config"
          ];

          extraOptions = [
            "--network=ai"
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

  };
}
