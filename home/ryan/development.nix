{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    gdb
    gcc
    gnumake
    cmake

    python312
    nodejs_22

    # add distrobox
    distrobox
    boxbuddy
    mupdf

    android-tools

    dbeaver-bin

    remmina

    android-studio
    jetbrains.pycharm-professional
    jetbrains.webstorm
    jetbrains.idea-ultimate
    jetbrains.clion
    jetbrains.rust-rover
    jetbrains.rider
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
      "cmake.showOptionsMovedNotification" = false;
      "cmake.pinnedCommands" = [
        "workbench.action.tasks.configureTaskRunner"
        "workbench.action.tasks.runTask"
      ];
    };
  };

  # Declarative virtmanager configuration, not sure where to place this
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    coc.enable = true;
    coc.pluginConfig = "";
    coc.settings = {};

    plugins = with pkgs.vimPlugins; [
      vim-fugitive
      vim-vinegar
      # nodePackages.bash-language-server
      # nodePackages.typescript-language-server
      # nodePackages.vim-language-server
      # nodePackages.yaml-language-server
      # python310Packages.python-lsp-server

      coc-python
      coc-spell-checker
      coc-sh
      coc-rust-analyzer
      coc-prettier
      coc-nginx
      coc-lua
      coc-json
      coc-toml
      coc-java
      coc-html
      coc-css
      coc-tsserver
      coc-cmake
      coc-docker
      coc-git
    ];
  };
}
