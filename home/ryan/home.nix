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
    ./social.nix

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
    preferXdgDirectories = true;
    sessionPath = [
      "$HOME/nix-config/scripts"
      "$HOME/.local/bin"
      "$HOME/bin"
    ];
    sessionVariables = {
      EDITOR = lib.mkForce "vim";
      VISIAL = "vim";
      PAGER = "less";
      LESS = "-R";
      BROWSER = "firefox";
      TERMINAL = "kitty";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "hyprland";
      XDG_SESSION_CLASS = "user";
    };

    shellAliases = {
      # Allows sudo to be used with aliases
      sudo = "sudo ";

      # GIT aliases
      g = "git";
      gc = "git commit";
      gcm = "git commit -m";
      gr = "git rebase";
      gp = "git push";
      gu = "git unstage";
      gf = "git fetch";
      gco = "git checkout";
      gb = "git branch";

      nix-switch = "sudo nixos-rebuild switch";

      serve = "python3 -m http.server";
    };
  };

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    extraConfig = ''
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

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
