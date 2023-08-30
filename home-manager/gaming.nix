{pkgs, ... }:
{
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
    ];
}