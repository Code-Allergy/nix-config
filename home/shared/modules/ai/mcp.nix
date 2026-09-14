{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.neer.modules.ai.mcp;
  json = pkgs.formats.json {};
  credentialDir = "${config.xdg.configHome}/mcp/credentials";
  ompEnabled = config.neer.modules.ai.omp.enable || config.neer.modules.ai.oh-my-pi.enable;

  ompServers =
    lib.mapAttrs (
      _: server:
        builtins.removeAttrs server ["headerFiles"]
        // lib.optionalAttrs (server.headerFiles != {}) {
          headers =
            (server.headers or {})
            // lib.mapAttrs (
              _: path: "!${pkgs.coreutils}/bin/cat ${lib.escapeShellArg path}"
            )
            server.headerFiles;
        }
    )
    cfg.servers;

  openCodeServers =
    lib.mapAttrs (
      _: server:
        builtins.removeAttrs server [
          "type"
          "command"
          "args"
          "env"
          "headerFiles"
        ]
        // {
          type =
            if server.type == "stdio"
            then "local"
            else "remote";
        }
        // lib.optionalAttrs (server.headerFiles != {}) {
          headers = (server.headers or {}) // lib.mapAttrs (_: path: "{file:${path}}") server.headerFiles;
        }
        // lib.optionalAttrs (server.type == "stdio") {
          command = [server.command] ++ (server.args or []);
          environment = server.env or {};
        }
    )
    cfg.servers;

  ompConfig = json.generate "omp-mcp.json" {
    "$schema" = "https://raw.githubusercontent.com/can1357/oh-my-pi/main/packages/coding-agent/src/config/mcp-schema.json";
    mcpServers = ompServers;
  };
  openCodeConfig = json.generate "opencode.jsonc" (
    cfg.openCodeSettings
    // {
      "$schema" = "https://opencode.ai/config.json";
      mcp = openCodeServers;
    }
  );
in {
  options.neer.modules.ai.mcp = {
    enable = lib.mkEnableOption "shared MCP configuration and encrypted credentials";
    servers = lib.mkOption {
      description = "Shared OMP-format server definitions. Use headerFiles for secret headers, never plaintext credentials.";
      type = lib.types.attrsOf (
        lib.types.submodule {
          freeformType = json.type;
          options = {
            type = lib.mkOption {
              type = lib.types.enum [
                "http"
                "stdio"
              ];
              default = "http";
            };
            headerFiles = lib.mkOption {
              type = lib.types.attrsOf lib.types.str;
              default = {};
              description = "Header names mapped to decrypted files read by each client at runtime.";
            };
          };
        }
      );
      default = {
        chief-jira = {
          url = "https://mcp.atlassian.com/v2/mcp";
          headerFiles.Authorization = config.age.secrets.mcp-chief-jira.path;
        };
        context7.url = "https://mcp.context7.com/mcp";
        grafana = {
          url = "https://api.ampere.bigblubbus.duckduck112.duckdns.org/mcp";
          headers."x-litellm-api-key" = "{env:AMPERE_API_KEY}";
        };
        nixos = {
          type = "stdio";
          command = "${pkgs.nix}/bin/nix";
          args = [
            "run"
            "github:utensils/mcp-nixos"
            "--"
          ];
        };
        trilium-notes = {
          url = "http://127.0.0.1:37840/mcp";
          headerFiles.Authorization = config.age.secrets.mcp-trilium-notes.path;
        };
      };
    };
    openCodeSettings = lib.mkOption {
      type = json.type;
      default = {
        plugin = ["opencode-wakatime"];
        lsp = true;
        formatter = true;
      };
      description = "OpenCode settings merged with the generated shared MCP definitions.";
    };
  };

  config = lib.mkIf cfg.enable {
    age.identityPaths = ["${config.xdg.configHome}/agenix/keys.txt"];
    age.secrets = {
      mcp-chief-jira = {
        file = ../../secrets/mcp-chief-jira.age;
        path = "${credentialDir}/chief-jira";
      };
      mcp-trilium-notes = {
        file = ../../secrets/mcp-trilium-notes.age;
        path = "${credentialDir}/trilium-notes";
      };
    };

    # Keep client files writable: both applications can update their own config.
    # Home Manager restores the central definitions on each activation.
    home.activation.mcpConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Refresh credentials on switch as well as through the agenix login service.
      ${lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
        run ${lib.escapeShellArgs config.systemd.user.services.agenix.Service.ExecStart}
      ''}
      ${lib.optionalString config.neer.modules.ai.opencode.enable ''
        run install -D -m 600 ${openCodeConfig} ${lib.escapeShellArg "${config.xdg.configHome}/opencode/opencode.jsonc"}
      ''}
      ${lib.optionalString ompEnabled ''
        run install -D -m 600 ${ompConfig} ${lib.escapeShellArg "${config.home.homeDirectory}/.omp/agent/mcp.json"}
      ''}
    '';
  };
}
