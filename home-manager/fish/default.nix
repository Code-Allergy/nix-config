{ pkgs, ... }:

{
    programs.fish = {
        enable = true;
        interactiveShellInit = ''
            set fish_greeting # disable welcome message
        '';
        plugins = [
            { name = "done"; src = pkgs.fishPlugins.done.src; }
            { name = "colour-man"; src = pkgs.fishPlugins.colored-man-pages.src; }
            { name = "autopair"; src = pkgs.fishPlugins.autopair.src; }
        ];
    };
}