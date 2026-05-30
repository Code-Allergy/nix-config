{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.global.config.development;
in
{
  options.global.config.development = {
    enable = mkEnableOption "Enable development home-manager configuration";
  };

  imports = [
    ./distrobox.nix
    ./git.nix
    ./nvim.nix
    ./ollama.nix
    ./rust.nix

    ./zed.nix
    ./vscode.nix
    ./jetbrains.nix
  ];

  config = mkIf cfg.enable {
    # TEMP
    home.packages = with pkgs; [
      # Make
      gnumake

      # GCC toolchain collection
      gdb
      gcc

      # CMake
      cmake

      # Python
      python3Minimal

      # Node.js
      nodejs-slim

      # Java
      jdk21_headless

      # android CLI tools
      android-tools
    ];

    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
