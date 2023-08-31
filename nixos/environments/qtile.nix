{
  services.xserver = {
    enable = true;
    layout = "us";
    windowManager.qtile.enable = true;
    windowManager.qtile.extraPackages = p: with p; [qtile-extras];
    displayManager.lightdm.enable = true;
  };
}
