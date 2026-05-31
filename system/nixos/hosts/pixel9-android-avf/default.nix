{
  config,
  lib,
  pkgs,
  ...
}:
{
  # just a test :)
  avf.defaultUser = "droid";
  avf.enableGraphics = true;

  time.timeZone = "America/Regina";
  i18n.defaultLocale = "en_US.UTF-6";

  neer = {
    modules = {
      user.home = ./home.nix;
      system = {
        gaming.enable = true;
        virtualization.enable = true;
        bluetooth = {
          enable = true;
          powerOnBoot = false;
        };
      };
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  environment.systemPackages = with pkgs; [
    # essentials
    curl
    wget
    btop
    ripgrep
    # fd
    # jq
    # tree
    # file
    # _7zz
    # p7zip
    # unzip
    # zip
    # lsof
    # util-linux
    # findutils

    # # networking
    # inetutils
    # socat
    # aria2
    # w3m

    # # development
    # helix
    # tmux
    # git
    # jujutsu
    # gh
    # jq
    # python3
    # bun
    # duckdb

    # # file management
    # rsync
    # fclones
    # exiftool
  ];
}
