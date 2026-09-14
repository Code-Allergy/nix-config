{
  config,
  lib,
  ...
}: let
  cfg = config.neer.modules.services.ai-inference;
  grafanaMcp = cfg.grafanaMcp;
in {
  options.neer.modules.services.ai-inference.grafanaMcp = {
    enable = lib.mkEnableOption "Grafana MCP server";

    image = lib.mkOption {
      type = lib.types.str;
      default = "docker.io/grafana/mcp-grafana:1.4.2";
      description = "Grafana MCP server container image.";
    };

    grafanaUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://grafana.${config.neer.network.rootDomain}";
      description = "Grafana base URL used by the MCP server.";
    };

    environmentFiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Environment files containing Grafana and MCP caller credentials.";
    };

    serverTokenEnvironmentVariable = lib.mkOption {
      type = lib.types.str;
      default = "MCP_GRAFANA_SERVER_TOKEN";
      description = "Environment variable containing the token LiteLLM uses to authenticate to Grafana MCP.";
    };

    allowAllKeys = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Expose Grafana MCP to all LiteLLM API keys without per-key MCP permissions.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["--disable-write"];
      description = "Additional mcp-grafana arguments; write operations are disabled by default.";
    };
  };

  config = lib.mkIf (cfg.enable && grafanaMcp.enable) {
    assertions = [
      {
        assertion = cfg.litellm.enable;
        message = "ai-inference.grafanaMcp requires ai-inference.litellm to be enabled";
      }
      {
        assertion = grafanaMcp.environmentFiles != [];
        message = "ai-inference.grafanaMcp requires an environment file containing Grafana credentials";
      }
    ];

    neer.modules.services.ai-inference.litellm.mcpServers.grafana = {
      server_id = "grafana";
      transport = "http";
      url = "http://grafana-mcp:8000/mcp";
      auth_type = "bearer_token";
      auth_value = "os.environ/${grafanaMcp.serverTokenEnvironmentVariable}";
      allow_all_keys = grafanaMcp.allowAllKeys;
      description = "Read-only Grafana observability tools";
    };

    virtualisation.oci-containers.containers.grafana-mcp = {
      image = grafanaMcp.image;
      autoStart = true;
      cmd =
        [
          "-t"
          "streamable-http"
          "--address"
          "0.0.0.0:8000"
        ]
        ++ grafanaMcp.extraArgs;
      environment = {
        GRAFANA_URL = grafanaMcp.grafanaUrl;
      };
      environmentFiles = grafanaMcp.environmentFiles;
      extraOptions = [
        "--network=${cfg.networkName}"
        "--security-opt=no-new-privileges"
      ];
    };

    systemd.services.podman-grafana-mcp = {
      requires = ["podman-network-ai.service"];
      after = ["podman-network-ai.service"];
    };

    systemd.services.podman-litellm = {
      wants = ["podman-grafana-mcp.service"];
      after = ["podman-grafana-mcp.service"];
    };
  };
}
