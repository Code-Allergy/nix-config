{pkgs, ...}: {
    # programs.pyenv.enable = true;

  home.packages = with pkgs; [
    gdb
    gcc
    bochs
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

  };
}