{
  pkgs,
  programs,
  ...
}: {
  home.packages = with pkgs; [
    steamcmd
    lutris
    bottles
    gamemode
    mangohud
    wine

    # needed for steam tray icon -- move if needed elsewhere

    prismlauncher

    # CC Emulator
    ccemux

    # Wii U Emulator
    cemu

    # Switch Emulators
    ryujinx

    # Osu!
    # TODO broke blubbus?
    # osu-lazer-bin
  ];
}
