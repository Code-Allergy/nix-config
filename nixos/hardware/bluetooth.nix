{pkgs, ...}: {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    package = pkgs.bluez;
    settings = {General = {Enable = "Source,Sink,Media,Socket";};};
  };

  services.blueman.enable = true;
}
