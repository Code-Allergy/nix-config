{
  config,
  lib,
  ...
}:

let
  cfg = config.neer.modules.services.ai-inference;
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
    

virtualisation.oci-containers.containers = {

  ollama = {
    image = "docker.io/ollama/ollama:latest";

    autoStart = true;
  
    volumes = [
      "/var/lib/ollama:/root/.ollama"
    ];
  
    environment = {
      OLLAMA_HOST = "0.0.0.0:11434";
      OLLAMA_NUM_PARALLEL = "1";
      OLLAMA_MAX_LOADED_MODELS = "1";
    };
  
    extraOptions = [
      "--network=ai"
      "--device=nvidia.com/gpu=all"
      "--security-opt=no-new-privileges"
    ];
  };

llama-cpp = {
  image = "ghcr.io/ggml-org/llama.cpp:server-cuda";
  autoStart = true;

  volumes = [
    "/var/lib/llama.cpp/models:/models"
  ];

  extraOptions = [
    "--network=ai"
    "--device=nvidia.com/gpu=all"
    "--security-opt=no-new-privileges"
  ];

  cmd = [
    "-m"
    #"/models/LFM2.5-8B-A1B-Q4_K_M.gguf"
    "/models/Ling-3.0-tiny-Q4_K_M.gguf"

  "--n-gpu-layers"
  "all"

"-fa"
"on"

    "--host"
    "0.0.0.0"

  "--ctx-size"
  "32768"

  "-np"
  "1"

  "--parallel"
  "1"

  "--jinja"

"--cache-type-k"
"f16"

"--cache-type-v"
"f16"

    "--batch-size" "2048"
    "--ubatch-size" "512"

  "--flash-attn"
  "on"

"--temp"
"1.0"

"--top-p"
"0.95"

"--top-k"
"20"

    "--port"
    "8080"

#"--alias"
#"minicpm5-2b"

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

systemd.services.podman-ollama = {
  requires = [ "podman-network-ai.service" ];
  after = [
    "podman-network-ai.service"
    "nvidia-container-toolkit-cdi-generator.service"
  ];
};

systemd.services.podman-open-webui = {
  requires = [ "podman-network-ai.service" ];
  after = [
    "podman-network-ai.service"
    "podman-ollama.service"
  ];
};


systemd.services.podman-llama-cpp = {
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
