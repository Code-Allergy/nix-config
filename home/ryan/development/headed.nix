{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    boxbuddy
    mupdf
    dbeaver-bin
    remmina
    android-studio

    zed-editor
    sublime-merge

    jetbrains.pycharm-professional
    jetbrains.webstorm
    jetbrains.idea-ultimate
    # jetbrains.clion
    jetbrains.rust-rover
    # jetbrains.rider
  ];

  # Disabled until dependency on Dotnet SDK 7.0.410 is updated (EOL)
  # programs.jetbrains-remote = {
  #   enable = true;
  #   ides = with pkgs.jetbrains; [
  #     pycharm-professional
  #     webstorm
  #     idea-ultimate
  #     clion
  #     rust-rover
  #     rider
  #   ];
  # };

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
}
