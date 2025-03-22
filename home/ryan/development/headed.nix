{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    boxbuddy
    mupdf
    dbeaver-bin
    remmina
    android-studio
    sublime-merge

    onlyoffice-bin
    libreoffice-qt
    hunspell
    hunspellDicts.uk_UA
    hunspellDicts.th_TH
    jetbrains.pycharm-professional
    jetbrains.webstorm
    jetbrains.idea-ultimate
    jetbrains.clion
    jetbrains.rust-rover
    jetbrains.rider
    package-version-server
  ];

  programs.jetbrains-remote = {
    enable = true;
    ides = with pkgs.jetbrains; [
      pycharm-professional
      webstorm
      idea-ultimate
      clion
      rust-rover
      rider
    ];
  };

  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "wakatime"
      "toml"
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
          EDITOR = "zed --wait";
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
            path = "/run/current-system/sw/bin/rust-analyzer";
          };
        };
        nil = {
          binary = {
            path = "/etc/profiles/per-user/ryan/bin/nil";
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
        rust-analyzer = {
          binary.path_lookup = true;
        };
        zls.binary.path_lookup = true;
        wakatime = {
          binary = {
            path = "/etc/profiles/per-user/ryan/bin/wakatime-ls";
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

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium-fhs;
    extensions = with pkgs.vscode-extensions; [
      ms-vscode.cpptools
      ms-vscode.hexeditor
      ms-vscode.makefile-tools
      ms-vscode.cmake-tools
      ms-vscode.hexeditor
      ms-vscode-remote.remote-ssh
      ms-python.python
      ms-python.vscode-pylance
      file-icons.file-icons
      esbenp.prettier-vscode
      vscjava.vscode-maven
      humao.rest-client

      # nix
      bbenoist.nix
      jnoortheen.nix-ide
      kamadorueda.alejandra
      arrterian.nix-env-selector

      firefox-devtools.vscode-firefox-debug

      # Theme
      catppuccin.catppuccin-vsc

      github.copilot

      # TODO git good
      # vscodevim.vim
    ];

    userSettings = {
      "cmake.configureOnOpen" = true;
      "window.menuBarVisibility" = "toggle";
      "[javascript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[html]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[typescriptreact]" = {
        "editor.defaultFormatter" = "vscode.typescript-language-features";
      };
      "[typescript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[nix]" = {
        "editor.defaultFormatter" = "kamadorueda.alejandra";
        "editor.formatOnPaste" = true;
        "editor.formatOnSave" = true;
        "editor.formatOnType" = false;
      };
      "[rust]" = {
        "editor.defaultFormatter" = "rust-lang.rust-analyzer";
        "editor.formatOnSave" = true;
      };
      "window.autoDetectColorScheme" = true;
      "terminal.explorerKind" = "external";
      "terminal.integrated.env.linux" = {
      };
      "liveServer.settings.doNotVerifyTags" = true;
      "rest-client.enableTelemetry" = false;
      "editor.fontFamily" = "'FiraCode Nerd Font','BlexMono Nerd Font', monospace";
      "editor.fontLigatures" = true;
      "git.autofetch" = true;

      "workbench.colorTheme" = "Catppuccin Mocha";
      "workbench.preferredDarkColorTheme" = "Catppuccin Mocha";
      "workbench.preferredLightColorTheme" = "Catppuccin Mocha";
      "cmake.showOptionsMovedNotification" = false;
      "cmake.pinnedCommands" = [
        "workbench.action.tasks.configureTaskRunner"
        "workbench.action.tasks.runTask"
      ];
    };
  };

  programs.mods = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    settings = {
      default-model = "llama3.2";
      apis = {
        ollama = {
          base-url = "http://localhost:11434/api";
          models = {
            "llama3.2" = {
              max-input-chars = 650000;
            };
          };
        };
      };
    };
  };
}
