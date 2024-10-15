{pkgs, ...}: {
  ## COMMON - HEADED
  imports = [
    ./fonts.nix
  ];

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-volman
      thunar-archive-plugin
    ];
  };
}
