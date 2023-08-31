{pkgs, ...}: {
  # programs.pyenv.enable = true;

  home.packages = with pkgs; [
    gdb
    gcc
    bochs

    android-tools

    dbeaver
  ];

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
      ms-python.vscode-pylance
      file-icons.file-icons
      esbenp.prettier-vscode
      vscjava.vscode-maven

      # nix
      bbenoist.nix
      kamadorueda.alejandra

      firefox-devtools.vscode-firefox-debug
      # Theme
      catppuccin.catppuccin-vsc
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
      "liveServer.settings.donotVerifyTags" = true;
      "rest-client.enableTelemetry" = false;
      "editor.fontFamily" = "'BlexMono Nerd Font Mono', 'monospace', monospace";
      "editor.fontLigatures" = true;
      "git.autofetch" = true;

      "workbench.colorTheme" = "Catppuccin Mocha";
    };
  };
}
