{
  pkgs,
  programs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.mcpelauncher-client
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.mcpelauncher-ui-qt

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
