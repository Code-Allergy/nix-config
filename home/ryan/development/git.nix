{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    maintenance.enable = true;
    userName = "Ryan Schaffer";
    userEmail = "rys686@mail.usask.ca";
    delta.enable = true;
    lfs.enable = true;
  };
  programs.gitui.enable = true; # rust git tui
}
