{pkgs, ...}: {
  # programs.pyenv.enable = true;

  home.packages = with pkgs; [
    gdb
    gcc
    bochs
    gnumake
    cmake
    nodejs

    android-tools

    dbeaver

    plantuml
    # Jetbrains
    jetbrains.pycharm-professional
    jetbrains.webstorm
    jetbrains.idea-ultimate
    jetbrains.clion
  ];

  programs.java.enable = true;
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
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
      kamadorueda.alejandra

      firefox-devtools.vscode-firefox-debug
      # Theme
      catppuccin.catppuccin-vsc

      vscodevim.vim
    ];

    userSettings = {
      "cmake.configureOnOpen" = true;
      "files.autoSave" = "afterDelay";
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
    };
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
