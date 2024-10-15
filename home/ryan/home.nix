{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  isHeaded,
  ...
}: {
  imports = lib.flatten [
    [
      (import ./development {inherit pkgs lib isHeaded;})
      ./shell
      ./keyring
      ./ssh
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

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
