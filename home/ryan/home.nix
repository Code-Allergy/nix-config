{
  lib,
  pkgs,
  isHeaded,
  ...
}:
{
  imports = lib.flatten [
    [
      ./shell
      ./keyring
      ./ssh
      ./yazi
    ]
    (lib.optionals isHeaded [
      ./communication.nix
      ./entertainment.nix
      (import ./syncthing { inherit pkgs lib isHeaded; }) # TEMP
      ./browsers
      ./kitty
      ./hypr
      ./obs.nix
      ./rofi
    ])
  ];

  # NEW modules config (2025)
  global.config = {
    development.enable = true;
  };

  # Common packages -- TO REMOVE
  home.packages = with pkgs; [
    # Document editing
    onlyoffice-bin
    libreoffice-qt
    hunspell
    hunspellDicts.uk_UA
    hunspellDicts.th_TH
  ];
  programs.bat.enable = true;

  catppuccin.flavor = "mocha";
  catppuccin.enable = true;

  # TEMP
  catppuccin.mako.enable = false;

  services.kdeconnect = {
    enable = true;
    package = pkgs.kdePackages.kdeconnect-kde;
    indicator = true;
  };

  # Unused, and crashing constantly as of June 29, 2025
  # services.conky = {
  #   enable = true;
  #   extraConfig = ''
  #     conky.config = {
  #         out_to_x = false,
  #         out_to_wayland = true,
  #     };
  #   '';
  # };

  # mime default applications
  xdg.mimeApps.defaultApplications = {
    "image/png" = "qview.desktop";
    "application/zip" = "ark.desktop";
  };

  services.copyq.enable = true;
  programs.pay-respects.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # bluetooth controls
  services.mpris-proxy.enable = true;

  # Declarative virtmanager configuration, not sure where to place this
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
