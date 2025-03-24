{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.global.config.gaming;
  headed = config.global.config.headless == false;
in
{
  options.global.config.gaming = {
    enable = mkEnableOption "Enable gaming home-manager configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; mkIf headed [
      # Steam tools
      steamcmd
      steamtinkerlaunch

      # Wine
      wine

      # Minecraft (JAVA) launcher
      prismlauncher

      # Minecraft (BEDROCK) launcher
      mcpelauncher-client
      mcpelauncher-ui-qt

      # Minecraft ComputerCraft Emulator
      ccemux

      # Wii/Gamecube Emulator
      dolphin-emu

      # Wii U Emulator
      cemu

      # Switch Emulator
      ryujinx
      suyu

      # PS3 Emulator
      rpcs3

      # PS2 Emulator
      pcsx2

      # Game save backup tool
      ludusavi

      # Heroic Games Launcher
      heroic
      gogdl
      legendary-heroic
    ];

    programs.mangohud = {
      enable = true;
    };
  };
}
