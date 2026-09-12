{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.neer.modules.services.ai-inference;
  proxy = cfg.reverseProxy;
  certificateDeployment = proxy.certificateDeployment;
  allowedRemoteRanges = lib.concatStringsSep " " proxy.allowedRemoteRanges;
  webuiSite = lib.optionals (cfg.openWebui.enable && proxy.webuiHost != null) [
    ""
    "${proxy.webuiHost} {"
    "\ttls /certs/fullchain.pem /certs/privkey.pem"
    "\tencode zstd gzip"
    "\treverse_proxy open-webui:8080"
    "}"
  ];
  accessDirectives =
    if proxy.allowedRemoteRanges == []
    then ["\treverse_proxy llama-swap:8080"]
    else [
      "\troute {"
      "\t\t@allowed remote_ip ${allowedRemoteRanges}"
      "\t\treverse_proxy @allowed llama-swap:8080"
      "\t\trespond 403"
      "\t}"
    ];
  caddyConfig = pkgs.writeText "ai-inference-Caddyfile" (lib.concatLines (
    [
      "{"
      "\tadmin off"
      "}"
    ]
    ++ webuiSite
    ++ [
      ""
      "${proxy.host} {"
      "\ttls /certs/fullchain.pem /certs/privkey.pem"
      "\tencode zstd gzip"
      ""
    ]
    ++ accessDirectives
    ++ ["}"]
  ));
in {
  options.neer.modules.services.ai-inference.reverseProxy = {
    enable = lib.mkEnableOption "Caddy reverse proxy for the AI inference API";

    host = lib.mkOption {
      type = lib.types.str;
      default = "${config.networking.hostName}.${config.neer.network.baseDomain}";
      example = "llm.example.com";
      description = "Fully qualified domain name for the llama-swap API.";
    };

    allowedRemoteRanges = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["10.10.10.10/32"];
      description = "Client IP ranges allowed to use the API; an empty list allows all clients.";
    };

    webuiHost = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "chat.example.com";
      description = "Optional public hostname for Open WebUI.";
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

    certificateDeployment = {
      enable = lib.mkEnableOption "restricted certificate deployment over SFTP";

      user = lib.mkOption {
        type = lib.types.str;
        default = "certsync";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "cert-deploy";
      };

      authorizedKeys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Restricted SSH public keys allowed to deploy certificates.";
      };
    };
  };

  config = lib.mkIf (cfg.enable && proxy.enable) {
    assertions = [
      {
        assertion = !certificateDeployment.enable || certificateDeployment.authorizedKeys != [];
        message = "ai-inference.reverseProxy.certificateDeployment requires at least one authorized key";
      }
      {
        assertion = proxy.webuiHost == null || cfg.openWebui.enable;
        message = "ai-inference.reverseProxy.webuiHost requires Open WebUI to be enabled";
      }
    ];

    neer.modules.services.ai-inference.reverseProxy = lib.mkIf certificateDeployment.enable {
      certificateOwner = lib.mkDefault certificateDeployment.user;
      certificateGroup = lib.mkDefault certificateDeployment.group;
    };

    users.groups = lib.optionalAttrs certificateDeployment.enable {
      ${certificateDeployment.group} = {};
    };

    users.users = lib.optionalAttrs certificateDeployment.enable {
      ${certificateDeployment.user} = {
        isSystemUser = true;
        group = certificateDeployment.group;
        home = proxy.certificateDirectory;
        createHome = false;
        shell = pkgs.bashInteractive;
        openssh.authorizedKeys.keys = certificateDeployment.authorizedKeys;
      };
    };

    services.openssh.extraConfig = lib.mkIf certificateDeployment.enable ''
      Match User ${certificateDeployment.user}
        AuthenticationMethods publickey
        PasswordAuthentication no
        KbdInteractiveAuthentication no
        ForceCommand internal-sftp
        PermitTTY no
        AllowTcpForwarding no
        X11Forwarding no
        PermitTunnel no
        PermitUserRC no

      Match all
    '';

    networking.firewall = {
      allowedTCPPorts = [80 443];
      allowedUDPPorts = [443];
    };

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

    systemd.services.podman-ai-reverse-proxy = {
      requires = ["podman-network-ai.service"];
      after = ["podman-network-ai.service"];
    };
  };
}
