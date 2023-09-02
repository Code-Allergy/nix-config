{
  services.xserver = {
    enable = true;
    layout = "us";
    windowManager.qtile.enable = true;
    windowManager.qtile.extraPackages = p: with p; [qtile-extras];
    displayManager.startx.enable = true;
    displayManager.lightdm.enable = true;
  };

  programs.dconf.enable = true;
}
