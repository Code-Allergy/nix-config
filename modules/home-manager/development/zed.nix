{
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
      #nodePackages.prettier

      nil
      nixfmt
      #wakatime-cli
      #inputs.tsutsumi.packages.${pkgs.stdenv.hostPlatform.system}.wakatime-ls

      # nix formatter + lsp
      alejandra
      nixd
    ];

    programs.zed-editor = {
      enable = true;
      package = pkgs.zed-editor.fhs;
      installRemoteServer = true;
      extensions = [
        "catppuccin-icons"
        "java"
        "nix"
        "wakatime"
      ];
      userSettings = {
        # ============================================
        # APPEARANCE & THEME
        # ============================================
        theme = {
          dark = "Catppuccin Mocha";
          light = "Catppuccin Mocha";
        };
        icon_theme = "Catppuccin Mocha";
        ui_font_size = 16;
        buffer_font_size = 14;
        colorize_brackets = true;
        indent_guides = {
          enabled = true;
          coloring = "indent_aware";
        };
        minimap = {
          show = "auto";
          thumb = "always";
          thumb_border = "left_open";
          current_line_highlight = "line";
        };
        scrollbar = {
          show = "auto";
          cursors = true;
          git_diff = true;
          search_results = true;
          selected_text = true;
          diagnostics = "all";
        };

        # ============================================
        # EDITOR BEHAVIOR
        # ============================================
        autosave = {
          after_delay = {
            milliseconds = 1000;
          };
        };
        inlay_hints = {
          enabled = true;
        };
        show_edit_predictions = true;
        load_direnv = "shell_hook";

        # ============================================
        # TABS & PREVIEW
        # ============================================
        tabs = {
          file_icons = true;
          git_status = true;
          show_diagnostics = "all";
          show_close_button = "hover";
        };
        preview_tabs = {
          enabled = true;
          enable_preview_from_file_finder = true;
          enable_preview_from_project_panel = true;
        };

        # ============================================
        # PANELS & DOCKS
        # ============================================
        project_panel = {
          button = true;
          dock = "left";
          file_icons = true;
          folder_icons = true;
          git_status = true;
          sticky_scroll = true;
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

        # ============================================
        # GIT INTEGRATION
        # ============================================
        git = {
          git_gutter = "tracked_files";
          inline_blame = {
            enabled = true;
            delay_ms = 500;
            show_commit_summary = true;
            min_column = 80;
          };
        };

        # ============================================
        # AI & AGENT
        # ============================================
        features = {
          edit_prediction_provider = "zed";
        };
        edit_predictions = {
          disabled_globs = [ ];
        };
        agent = {
          default_profile = "write";
          default_model = {
            provider = "copilot_chat";
            model = "claude-opus-4-5";
          };
          button = true;
          dock = "right";
          default_width = 640;
        };

        # ============================================
        # TERMINAL
        # ============================================
        terminal = {
          env = {
            EDITOR = "zeditor --wait";
          };
          cursor_shape = "bar";
          blinking = "terminal_controlled";
          copy_on_select = true;
          detect_venv = {
            on = {
              directories = [
                ".env"
                "env"
                ".venv"
                "venv"
              ];
              activate_script = "default";
            };
          };
        };

        # ============================================
        # SESSION & STARTUP
        # ============================================
        restore_on_startup = "last_session";
        session = {
          restore_unsaved_buffers = true;
        };

        # ============================================
        # EXTENSIONS (auto-install)
        # ============================================
        auto_install_extensions = {
          catppuccin-icons = true;
          java = true;
          nix = true;
          wakatime = true;
        };

        # ============================================
        # FILE HANDLING
        # ============================================
        file_types = {
          Dockerfile = [ "Dockerfile*" ];
          JSON = [
            "json"
            "jsonc"
          ];
        };
        file_scan_exclusions = [
          "**/.git"
          "**/.svn"
          "**/.hg"
          "**/CVS"
          "**/.DS_Store"
          "**/Thumbs.db"
          "**/.classpath"
          "**/.settings"
        ];

        # ============================================
        # LANGUAGE-SPECIFIC SETTINGS
        # ============================================
        languages = {
          Make = {
            show_edit_predictions = true;
          };
          Nix = {
            language_servers = [
              "nil"
              "!nixd"
            ];
            tab_size = 2;
          };
        };

        # ============================================
        # LSP CONFIGURATION
        # ============================================
        lsp = {
          nil = {
            initialization_options = {
              formatting = {
                command = [ "nixfmt" ];
              };
            };
          };
          rust-analyzer = {
            initialization_options = {
              rust = {
                analyzerTargetDir = true;
              };
            };
          };
          # Unneeded for FHS test
          # wakatime = {
          #   binary = {
          #     arguments = [
          #       "--wakatime-cli"
          #       "/etc/profiles/per-user/ryan/bin/wakatime-cli"
          #     ];
          #   };
          # };
        };

        # ============================================
        # PRIVACY & TELEMETRY
        # ============================================
        telemetry = {
          diagnostics = false;
          metrics = false;
        };
      };
    };
  };
}
