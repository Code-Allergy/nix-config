{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  isHeaded,
  catppuccin,
  ...
}: {
  imports = lib.flatten [
    [
      ./development
      ./shell
      ./keyring
      ./ssh
      ./yazi
    ]
    (lib.optionals isHeaded [
      ./communication.nix
      ./entertainment.nix
      ./gaming.nix
      (import ./syncthing {inherit pkgs lib isHeaded;}) # TEMP
      ./browsers
      ./kitty
      ./hypr
    ])
  ];

  # Common packages
  home.packages = with pkgs; [
    # run any package with ,
    comma

    # CLI tools we want everywhere
    htop
    bottom
    bat
    eza
    killall
    file

    # dotfile management
    git-crypt

    # nix formatter + lsp
    alejandra
    nixd
  ];
  catppuccin.flavor = "mocha";
  catppuccin.enable = true;

  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  programs.thefuck.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
