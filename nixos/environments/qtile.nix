{
  pkgs,
  config,
  ...
}: {
  services.xserver = {
    enable = true;
    layout = "us";
    windowManager.qtile.enable = true;
    #windowManager.qtile.backend = "wayland";
    windowManager.qtile.extraPackages = p: with p; [qtile-extras];
    # displayManager.startx.enable = true;
    displayManager.lightdm.enable = true;
    displayManager.lightdm.greeters.enso.enable = true;
  };
  programs.xss-lock.enable = true;

  programs.dconf.enable = true;

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="nvidia_wmi_ex_backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="nvidia_wmi_ex_backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
  '';

  environment.systemPackages = [
    pkgs.lightlocker
  ];
}
