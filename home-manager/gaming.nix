{pkgs, ...}: {
  home.packages = with pkgs; [
    steamcmd
    steam
    lutris
    bottles
    gamemode
    mangohud
    gamescope
    wine

    prismlauncher

    # CC Emulator
    ccemux

    # Wii U Emulator
    cemu

    # Switch Emulators
    ryujinx
    yuzu-mainline

    # Osu!
    osu-lazer-bin
  ];
}
