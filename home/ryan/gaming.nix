{
  pkgs,
  programs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    mcpelauncher-client
    mcpelauncher-ui-qt

    steamcmd
    gamemode
    mangohud
    wine

    prismlauncher

    # CC Emulator
    ccemux

    # Wii U Emulator
    cemu

    # Switch Emulator
    ryujinx

    # PS3 Emulator
    rpcs3

    # PS2 Emulator
    pcsx2

    # Game saves
    ludusavi

    # Heroic Games Launcher
    heroic
    gogdl
    legendary-heroic
  ];

  programs.mangohud = {
    enable = true;
    enableSessionWide = true;
    # settings =
  };
}
