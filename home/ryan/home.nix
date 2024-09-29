{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    ./communication.nix
    ./gaming.nix
    ./entertainment.nix
    ./development.nix

    ./syncthing

    ./browsers
    ./kitty
    ./shell

    ./hypr
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  home = {
    username = "ryan";
    homeDirectory = "/home/ryan";
  };

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    extraConfig = ''
      Host vada.life
        HostName vada.life
        IdentityFile ~/.ssh/id_ed25519

      Host blubbus
        HostName 192.168.1.206
        User ryan

      Host bigblubbus
        HostName 192.168.1.124
        User ryan

      Host tuxworld
        HostName tuxworld.usask.ca
        User rys686

      Host cmpt332-amd64
        HostName cmpt332-amd64
        User rys686
        ProxyJump tuxworld

      Host cmpt332-arm
        HostName cmpt332-arm
        User rys686
        ProxyJump tuxworld

      Host cmpt332-ppc
        HostName cmpt332-ppc
        User rys686
        ProxyJump tuxworld
    '';
  };

  programs.git = {
    enable = true;
    userName = "Ryan Schaffer";
    userEmail = "rys686@mail.usask.ca";
    diff-so-fancy.enable = true;
  };

  # gnome-keyring
  services.gnome-keyring = {
    enable = true;
    components = ["pkcs11" "secrets" "ssh"];
  };

  systemd.user.services.keyring-daemon = {
    Unit = {
      Description = "GNOME Keyring daemon";
      PartOf = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.gnome.gnome-keyring}/bin/gnome-keyring-daemon --foreground --components=secrets,ssh,pkcs11";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
