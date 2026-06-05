{
  pkgs ? import <nixpkgs> { },
}:
let
  # nixConf = import ./nix/conf.nix;
  options = [
    ''--option experimental-features "nix-command flakes"''
  ];
in
pkgs.mkShell {
  name = "neer";
  nativeBuildInputs = with pkgs; [
    git
    git-crypt
    jq
  ];

  shellHook = ''
    PATH=${pkgs.writeShellScriptBin "neer-print" ''
      #!${pkgs.stdenv.shell}
      set -euo pipefail
      if [ $# -lt 1 ]; then
        echo "Usage: neer-print <host> [system|home]" >&2
        exit 1
      fi
      host="$1"
      typ="$2"
      if [ -z "$typ" ]; then typ="system"; fi
      case "$typ" in
        system)
          ${pkgs.nixVersions.stable}/bin/nix eval --json .#nixosConfigurations."$host".config.neer | ${pkgs.jq}/bin/jq .
          ;;
        home)
          ${pkgs.nixVersions.stable}/bin/nix eval --json --impure --expr "(import ./system/nixos/hosts/$host/home.nix {})" | ${pkgs.jq}/bin/jq .
          ;;
        *)
          echo "Unknown type: $typ" >&2
          exit 2
          ;;
      esac
    ''}/bin:${pkgs.writeShellScriptBin "nix" ''
      ${pkgs.nixVersions.stable}/bin/nix ${builtins.concatStringsSep " " options} "$@"
    ''}/bin:$PATH
  '';
}
