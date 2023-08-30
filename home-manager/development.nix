{pkgs, ...}: {
    # programs.pyenv.enable = true;

  home.packages = with pkgs; [
    gdb
    gcc
    bochs

    android-tools
    
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      ms-vscode.cpptools
      ms-vscode.hexeditor
      ms-vscode.cmake-tools
      ms-vscode-remote.remote-ssh
      ms-python.vscode-pylance
      file-icons.file-icons

      firefox-devtools.vscode-firefox-debug

      # Theme
      catppuccin.catppuccin-vsc
    ];
  };
}