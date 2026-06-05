{ lib, ... }:

with builtins;
with lib;
{
  imports =
    let
      dirs = filterAttrs (n: v: v != null && !(hasPrefix "_" n) && (v == "directory")) (readDir ./.);
      paths = map (x: "${toString ./.}/${x}") (attrNames dirs);
    in
    paths;

  # flatpaks are enabled at the home level.
  services.flatpak = {
    enable = true;
    packages = [
      "com.github.tchx84.Flatseal"
    ];
  };
}
