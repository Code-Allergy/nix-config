{
  lib,
  pkgs,
  isHeaded,
  ...
}:
{
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
      (import ./syncthing { inherit pkgs lib isHeaded; }) # TEMP
      ./browsers
      ./kitty
      ./hypr
      ./obs.nix
      ./rofi
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

    # sshfs
    sshfs
  ];
  catppuccin.flavor = "mocha";
  catppuccin.enable = true;

  services.kdeconnect = {
    enable = true;
    package = pkgs.kdePackages.kdeconnect-kde;
    indicator = true;
  };

  services.conky = {
    enable = true;
    extraConfig = ''
      conky.config = {
          out_to_x = false,
          out_to_wayland = true,
      };
    '';
  };

  # mime default applications
  xdg.mimeApps.defaultApplications = {
    "image/png" = "qview.desktop";
    "application/zip" = "ark.desktop";
  };

  services.copyq.enable = true;

  programs.thefuck.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # bluetooth controls
  services.mpris-proxy.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
