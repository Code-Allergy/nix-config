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
  cfg = devCfg.vscode;
in
{
  options.global.config.development.vscode.enable = mkEnableOption "Enable VSCode" // {
    default = devCfg.enable && headed; # Inherit enable state from main module
  };

  config = mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium-fhs;
      profiles.default = {
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
          # catppuccin.catppuccin-vsc

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
    };
  };
}
