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
      # Normal / fast profile for Ling
      ling-3.0-tiny-256k:
        name: "Ling 3.0 Tiny XL"
        description: "Ling 3.0 Tiny XL - 256k context"
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


      ling-3.0-tiny-128k:
        name: "Ling 3.0 Tiny XL"
        description: "Ling 3.0 Tiny XL - 128k context"
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


    profiles:
      normal:
        description: "Normal interactive inference"
        pins:
          chat: ling-3.0-tiny-128k

      long-context:
        description: "Large context work"
        pins:
          chat: ling-3.0-tiny-256k

    hooks:
      on_startup:
        profile: normal
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
            OLLAMA_BASE_URL = "http://ollama:11434";
            ENABLE_OLLAMA_API = "true";
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
