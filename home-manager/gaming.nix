{pkgs, programs, ...}: {
  home.packages = with pkgs; [
    steamcmd
    steam
    lutris
    bottles
    gamemode
    mangohud
    gamescope
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
    osu-lazer-bin
  ];
}
