{
  pkgs,
  lib,
  isHeaded,
  ...
}:
{
  services.syncthing.enable = true;

  home.packages =
    with pkgs;
    lib.flatten [
      [
      ]
      (lib.optionals isHeaded [
        syncthingtray
      ])
    ];
}
