{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.neer.modules.services.ai-inference;
  proxy = cfg.reverseProxy;
  caddyConfig = pkgs.writeText "ai-inference-Caddyfile" ''
    {
      admin off
    }

    ${proxy.webuiHost} {
      tls /certs/fullchain.pem /certs/privkey.pem
      encode zstd gzip
      reverse_proxy open-webui:8080
    }

    ${proxy.apiHost} {
      tls /certs/fullchain.pem /certs/privkey.pem
      encode zstd gzip
      reverse_proxy llama-swap:8080
    }
  '';
in {
  options.neer.modules.services.ai-inference.reverseProxy = {
    enable = lib.mkEnableOption "public Caddy reverse proxy for AI inference";

    webuiHost = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "ai.example.com";
    };

    apiHost = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "llm.example.com";
    };

    image = lib.mkOption {
      type = lib.types.str;
      default = "docker.io/library/caddy:2";
    };

    stateDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/caddy";
    };

    certificateDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/caddy/certs";
    };

    certificateOwner = lib.mkOption {
      type = lib.types.str;
      default = "root";
    };

    certificateGroup = lib.mkOption {
      type = lib.types.str;
      default = "root";
    };
  };

  config = lib.mkIf (cfg.enable && proxy.enable) {
    assertions = [
      {
        assertion = proxy.webuiHost != null && proxy.apiHost != null;
        message = "ai-inference.reverseProxy requires webuiHost and apiHost";
      }
      {
        assertion = cfg.openWebui.enable;
        message = "ai-inference.reverseProxy requires Open WebUI to be enabled";
      }
    ];

    systemd.tmpfiles.rules = [
      "d ${proxy.stateDirectory} 0750 root ${proxy.certificateGroup} -"
      "d ${proxy.stateDirectory}/data 0750 root root -"
      "d ${proxy.stateDirectory}/config 0750 root root -"
      "d ${proxy.certificateDirectory} 0750 ${proxy.certificateOwner} ${proxy.certificateGroup} -"
    ];

    virtualisation.oci-containers.containers.ai-reverse-proxy = {
      image = proxy.image;
      autoStart = true;
      ports = [
        "80:80"
        "443:443"
        "443:443/udp"
      ];
      volumes = [
        "${caddyConfig}:/etc/caddy/Caddyfile:ro"
        "${proxy.certificateDirectory}/fullchain.pem:/certs/fullchain.pem:ro"
        "${proxy.certificateDirectory}/privkey.pem:/certs/privkey.pem:ro"
        "${proxy.stateDirectory}/data:/data"
        "${proxy.stateDirectory}/config:/config"
      ];
      extraOptions = [
        "--network=${cfg.networkName}"
        "--security-opt=no-new-privileges"
      ];
    };

    virtualisation.oci-containers.containers.open-webui.environment = {
      WEBUI_URL = "https://${proxy.webuiHost}";
      CORS_ALLOW_ORIGIN = "https://${proxy.webuiHost}";
      WEBUI_SESSION_COOKIE_SECURE = "true";
    };

    systemd.services.podman-ai-reverse-proxy = {
      requires = ["podman-network-ai.service"];
      after = ["podman-network-ai.service"];
    };
  };
}
