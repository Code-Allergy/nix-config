{
  pkgs,
  programs,
  ...
}: {
  home.packages = with pkgs; [
    steamcmd
    gamemode
    mangohud
    wine

    prismlauncher

    # CC Emulator
    ccemux

    # Wii U Emulator
    cemu

    # Switch Emulators
    ryujinx
  ];

  programs.mangohud = {
    enable = true;
    enableSessionWide = true;
    # settings =
  };
}
