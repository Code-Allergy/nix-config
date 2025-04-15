{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  devCfg = config.global.config.development;
  headed = config.global.config.headless == false;
  cfg = devCfg.zed;
in
{
  options.global.config.development.zed.enable = mkEnableOption "Enable Zed" // {
    default = devCfg.enable && headed; # Inherit enable state from main module
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      package-version-server

      nil
      nixfmt-rfc-style
      wakatime
      inputs.tsutsumi.packages.${pkgs.system}.wakatime-ls

      # nix formatter + lsp
      alejandra
      nixd
    ];

    programs.zed-editor = {
      enable = true;
      package = pkgs.zed-editor;
      extensions = [
        "nix"
        "wakatime"
        "java"

        # # Build
        # "make"
        # "just"

        # # Formats
        # "toml"
        # "cargo-tom"
        # "csv"
        # "ini"
        # "scheme"
        # "asciidoc"
        # "http"
      ];
      installRemoteServer = true;
      userSettings = {
        assistant = {
          default_model = {
            provider = "copilot_chat";
            model = "claude-3-7-sonnet";
          };
          version = "2";
        };
        # language_models = {
        #   ollama = {
        #     api_url = "http://localhost:11434";
        #   };
        # };
        inlay_hints = {
          enabled = true;
        };
        # features = {
        #   edit_prediction_provider = "zed";
        # };
        terminal = {
          env = {
            EDITOR = "zeditor --wait";
          };
        };
        file_types = {
          Dockerfile = [
            "Dockerfile"
            "Dockerfile.*"
          ];
          JSON = [
            "json"
            "jsonc"
            "*.code-snippets"
          ];
        };
        file_scan_exclusions = [
          # Zed defaults
          "**/.git"
          "**/.svn"
          "**/.hg"
          "**/CVS"
          "**/.DS_Store"
          "**/Thumbs.db"
          "**/.classpath"
          "**/.settings"
        ];
        telemetry = {
          diagnostics = false;
          metrics = false;
        };
        project_panel = {
          button = true;
          dock = "left";
        };
        outline_panel = {
          dock = "right";
        };
        collaboration_panel = {
          dock = "left";
        };
        notification_panel = {
          dock = "left";
        };
        chat_panel = {
          dock = "left";
        };
        lsp = {
          rust-analyzer = {
            initialization_options = {
              rust = {
                analyzerTargetDir = true;
              };
            };
            binary = {
              path_lookup = true;
            };
          };
          nil = {
            binary = {
              path_lookup = true;
            };
            initialization_options = {
              formatting = {
                command = [ "nixfmt" ];
              };
            };
          };
          nix = {
            binary = {
              path_lookup = true;
            };
          };
          zls.binary.path_lookup = true;
          wakatime = {
            binary = {
              path_lookup = true;
              arguments = [
                "--wakatime-cli"
                "/etc/profiles/per-user/ryan/bin/wakatime-cli"
              ];
            };
          };
        };
        languages = {
          Nix = {
            tab_size = 2;
            language_servers = [
              "nil"
              "!nixd"
            ];
          };
        };
        autosave.after_delay.milliseconds = 1000;
        load_direnv = "shell_hook";
        ui_font_size = 16;
        buffer_font_size = 14;
      };
    };
  };
}
