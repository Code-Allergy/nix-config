{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  nixConfigRoot,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # Core configurations
    ./communication.nix
    ./gaming.nix
    ./entertainment.nix
    ./development.nix

    # Service configurations
    ./syncthing

    # Application configurations
    ./browsers
    ./kitty
    ./shell

    # Desktop environment
    ./hypr
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  home = {
    username = "ryan";
    homeDirectory = "/home/ryan";
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      MANPAGER = "nvim +Man!";
      BROWSER = "firefox";
      NIX_CONFIG_ROOT = nixConfigRoot;
    };
  };

  programs.ssh = {
    enable = true;
    addKeysToAgent = lib.mkForce "yes";
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
    extraConfig = {
      color.ui = true;
      diff.tool = "diff-so-fancy";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
