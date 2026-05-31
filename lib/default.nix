{ inputs, self }:
let
  lib = inputs.nixpkgs.lib;
in
rec {
  inherit (lib)
    hasInfix
    hasPrefix
    mkIf
    mkMerge
    mkOption
    optionalAttrs
    types
    ;

  firstOrDefault = first: default: if first != null then first else default;

  existsOrDefault =
    name: set: default:
    if builtins.hasAttr name set then builtins.getAttr name set else default;

  strToPath =
    x: path: if builtins.typeOf x == "string" then builtins.toPath ("${toString path}/${x}") else x;

  strToFile =
    x: path: if builtins.typeOf x == "string" then builtins.toPath ("${toString path}/${x}.nix") else x;

  isPasswdCompatible = str: !(hasInfix ":" str || hasInfix "\n" str);

  passwdEntry =
    type:
    types.addCheck type isPasswdCompatible
    // {
      name = "passwdEntry ${type.name}";
      description = "${type.description}, not containing newlines or colons";
    };

  mkUserHome =
    {
      userConf,
      username ? userConf.userName,
      configName ? username,
      config ? ../home/shared/modules/users/${configName}-home.nix,
      system ? "x86_64-linux",
      homeDirectory ? null,
      extraModules ? [ ],
      ...
    }:
    let
      resolvedHomeDirectory =
        if homeDirectory != null then
          homeDirectory
        else if hasPrefix "darwin" system then
          "/Users/${username}"
        else
          "/home/${username}";
    in
    {
      imports = [
        (import ../home/shared/modules)
        inputs.catppuccin.homeModules.catppuccin
        (import config)
      ]
      ++ extraModules;

      home = {
        inherit username;
        homeDirectory = resolvedHomeDirectory;
      };
    };
}
