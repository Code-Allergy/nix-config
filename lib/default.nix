{ inputs, ... }:

with inputs;
with inputs.nixpkgs;
with inputs.nixpkgs.lib;

let

  # Shared home-manager config used by both mkUserHome (system-level) and mkArchConfiguration (standalone).
  mkCommonHomeConfig = {
    home.stateVersion = "24.05";

    # For compatibility with nix-shell, nix-build, etc.
    home.file.".nixpkgs".source = inputs.nixpkgs;
    home.sessionVariables = {
      NIX_PATH = "nixpkgs=$HOME/.nixpkgs\${NIX_PATH:+:}$NIX_PATH";
      EDITOR = "nvim";
      VISUAL = "nvim";
      COLORTERM = "truecolor";
    };

    # Use the same Nix configuration for the user
    xdg.configFile."nixpkgs/config.nix".source = ../nix/config.nix;

    # Re-expose self and nixpkgs as flakes.
    xdg.configFile."nix/registry.json".text = builtins.toJSON {
      version = 2;
      flakes =
        let
          toInput =
            input:
            {
              type = "path";
              path = input.outPath;
            }
            // (filterAttrs (
              n: _: n == "lastModified" || n == "rev" || n == "revCount" || n == "narHash"
            ) input);
        in
        [
          {
            from = {
              id = "neer";
              type = "indirect";
            };
            to = toInput inputs.self;
          }
          {
            from = {
              id = "nixpkgs";
              type = "indirect";
            };
            to = toInput inputs.nixpkgs;
          }
        ];
    };
  };

  # Extra config only for standalone homeConfigurations (not used inside system-level home-manager
  # where useGlobalPkgs=true disables nixpkgs options and nix.package is set by common.nix).
  mkStandaloneHomeConfig =
    { system }:
    {
      xdg.configFile."nix/nix.conf".text = ''
        experimental-features = nix-command flakes
      '';

      nix = {
        package = inputs.self.legacyPackages."${system}".nixVersions.stable;
        extraOptions = "experimental-features = nix-command flakes";
      };

      nixpkgs = {
        config = import ../nix/config.nix;
        overlays = inputs.self.overlays."${system}";
      };
    };

in
rec {

  firstOrDefault = first: default: if first != null then first else default;

  existsOrDefault =
    name: set: default:
    if builtins.hasAttr name set then builtins.getAttr name set else default;

  mkUserHome =
    {
      config,
      userConf,
      system ? "aarch64-darwin",
    }:
    { ... }:
    {
      imports = [
        # (hyprland.homeManagerModules.default)
        # (agenix.homeManagerModules.default)
        # (import ../home/darwin/modules)
        (import ../home/nixos/modules)
        (import config)
        mkCommonHomeConfig
      ];
    };

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

  # mkUserHome =
  #   {
  #     userConf,
  #     username ? userConf.userName,
  #     configName ? username,
  #     config ? ../home/shared/modules/users/${configName}-home.nix,
  #     system ? "x86_64-linux",
  #     homeDirectory ? null,
  #     extraModules ? [ ],
  #     ...
  #   }:
  #   let
  #     resolvedHomeDirectory =
  #       if homeDirectory != null then
  #         homeDirectory
  #       else if hasPrefix "darwin" system then
  #         "/Users/${username}"
  #       else
  #         "/home/${username}";
  #   in
  #   {
  #     imports = [
  #       (import ../home/shared/modules)
  #       inputs.catppuccin.homeModules.catppuccin
  #       (import config)
  #     ]
  #     ++ extraModules;

  #     home = {
  #       inherit username;
  #       homeDirectory = resolvedHomeDirectory;
  #     };
  #   };

  mkHomeConfiguration =
    {
      self,
      system,
      username,
      configName ? username,
      hostname ? configName,
      homeDirectory ? null,
      extraModules ? [ ],
      ...
    }:
    let
      userConf = import ../users/${configName}.nix;
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
        config = import ../nix/config.nix;
      };
      extraSpecialArgs = {
        inherit
          inputs
          self
          userConf
          username
          hostname
          system
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
        (import ../system/shared)
        (import ../system/nixos/modules)
        (../system/nixos/hosts + "/${hostname}")
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
              userConf
              system
              ;
            username = loginName;
          };
        }
        (
          { ... }:
          {
            system.stateVersion = "24.05";
          }
        )
        ../system/nixos/modules/user
      ];
    };
}
