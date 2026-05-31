{ inputs, ... }:

rec {
  inherit (inputs.nixpkgs.lib)
    attrValues
    filterAttrs
    genAttrs
    hasInfix
    hasPrefix
    mapAttrs
    mapAttrs'
    mkIf
    mkMerge
    mkOption
    nameValuePair
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

  mkHomeConfiguration =
    {
      self,
      system,
      username,
      configName ? username,
      hostname ? configName,
      isHeaded ? true,
      homeDirectory ? null,
      extraModules ? [ ],
      ...
    }:
    let
      userConf = import ../users/${configName}.nix;
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      extraSpecialArgs = {
        inherit
          inputs
          self
          userConf
          username
          hostname
          system
          isHeaded
          ;
      };
      modules = [
        (mkUserHome {
          inherit
            userConf
            username
            configName
            system
            homeDirectory
            extraModules
            ;
        })
      ];
    };

  mkNixosSystem =
    {
      self,
      hostname,
      username,
      isHeaded ? true,
      system ? "x86_64-linux",
      ...
    }:
    let
      userConf = import ../users/${username}.nix;
      loginName = userConf.userName or username;
    in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit
          inputs
          self
          hostname
          isHeaded
          userConf
          system
          ;
        username = loginName;
        user = userConf;
      };
      modules = [
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.nix-flatpak.nixosModules.nix-flatpak
        inputs.nixos-wsl.nixosModules.default
        ../cachix.nix
        ../system/shared
        ../system/nixos/common.nix
        (../system/nixos/hosts + "/${hostname}")
        (if isHeaded then ../system/nixos/headed.nix else ../system/nixos/headless.nix)
        ../system/nixos/modules/user
        inputs.catppuccin.nixosModules.catppuccin
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit
              inputs
              self
              hostname
              isHeaded
              userConf
              system
              ;
            username = loginName;
          };
          home-manager.users.${loginName} = mkUserHome {
            inherit userConf system;
            username = loginName;
            configName = username;
          };
        }
      ];
    };
}
