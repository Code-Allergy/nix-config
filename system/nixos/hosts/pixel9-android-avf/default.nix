{...}: {
  # just a test :)
  avf.defaultUser = "ryan";
  avf.enableGraphics = true;

  time.timeZone = "America/Regina";
  i18n.defaultLocale = "en_US.UTF-6";

  neer = {
    modules = {
      user.home = ./home.nix;
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # environment.systemPackages = with pkgs; [
  #   # essentials
  #   curl
  #   wget
  #   btop
  #   ripgrep
  # ];
}
