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
        (agenix.homeManagerModules.default)
        # (import ../home/darwin/modules)
        (catppuccin.homeModules.catppuccin)
        (nix-flatpak.homeManagerModules.nix-flatpak)
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

  mkNixSystemConfiguration =
    name:
    {
      config ? name,
      user ? "nixos",
      system ? "x86_64-linux",
      hostname ? "nixos",
      buildTarget,
      args ? { },
    }:
    nameValuePair name (
      let
        pkgs = inputs.self.legacyPackages."${system}";
        userConf = import (strToFile user ../users);
        unstable = import inputs.nixpkgs { inherit system; };
        #nixos = Dedicated Build on Metal
        nixosModules = [
          # (hyprland.nixosModules.default)
          (inputs.home-manager.nixosModules.home-manager)
          ({
            home-manager = {
              # useUserPackages = true;
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              sharedModules = [
                # inputs.nixvim.homeModules.nixvim
              ];
              extraSpecialArgs =
                let
                  self = inputs.self;
                  user = userConf;
                in
                # NOTE: Cannot pass name to home-manager as it passes `name` in to set the `hmModule`
                {
                  inherit
                    inputs
                    self
                    system
                    user
                    userConf
                    unstable
                    secrets
                    ;
                };
            };
          })
          (
            { ... }:
            {
              system.stateVersion = "24.05";
            }
          )
          (inputs.nixos-wsl.nixosModules.wsl)
          (inputs.lanzaboote.nixosModules.lanzaboote)
          (inputs.catppuccin.nixosModules.catppuccin)
          (inputs.agenix.nixosModules.default)
          (nix-flatpak.nixosModules.nix-flatpak)
          # (disko.nixosModules.disko)
          (import ../system/nixos/modules)
          (import ../system/shared)
          (import (strToPath config ../system/nixos/hosts))
        ];
        commonModules = [
          ({
            environment.systemPackages = [ agenix.packages.${system}.default ];
            age.identityPaths = [ "/home/${userConf.userName}/.ssh/id_rsa" ];

          })
          (
            { name, ... }:
            {
              networking.hostName = name;
            }
          )
          (
            { inputs, ... }:
            {
              # Use the nixpkgs from the flake.
              nixpkgs = { inherit pkgs; };

              # For compatibility with nix-shell, nix-build, etc.
              environment.etc.nixpkgs.source = inputs.nixpkgs;
              nix.nixPath = [ "nixpkgs=/etc/nixpkgs" ];
            }
          )
          (
            { pkgs, ... }:
            {
              # Don't rely on the configuration to enable a flake-compatible version of Nix.
              nix = {
                package = pkgs.nixVersions.stable;
                extraOptions = "experimental-features = nix-command flakes";
              };
            }
          )
          (
            { inputs, ... }:
            {
              # Re-expose self and nixpkgs as flakes.
              nix.registry = {
                self.flake = inputs.self;
                nixpkgs = {
                  from = {
                    id = "nixpkgs";
                    type = "indirect";
                  };
                  flake = inputs.nixpkgs;
                };
              };
            }
          )
          (
            { pkgs, ... }:
            {
              services.flatpak.enable = true;

            }
          )
          (import ../system/shared/secrets)
        ];
      in
      if buildTarget == "iso" then
        nixosSystem {
          inherit system;
          modules =
            commonModules
            ++ nixosModules
            ++ [
              #(import "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix") Default nix lib
              (inputs.nixos-generators.nixosModules.all-formats) # Community Nix Generators
            ];
          specialArgs =
            let
              self = inputs.self;
              user = userConf;
            in
            {
              inherit
                inputs
                name
                self
                system
                user
                userConf
                hostname
                secret
                ;
            };
        }
      else if buildTarget == "nixos-wsl" then
        nixosSystem {
          inherit system;
          modules = commonModules ++ nixosModules;
          specialArgs =
            let
              self = inputs.self;
              user = userConf;
            in
            {
              inherit
                inputs
                name
                self
                system
                user
                userConf
                hostname
                secrets
                ;
            };
        }
      ## handles nixos host builds
      else if buildTarget == "nixos" then
        nixosSystem {
          inherit system;
          modules = commonModules ++ nixosModules;
          specialArgs =
            let
              self = inputs.self;
              user = userConf;
            in
            {
              inherit
                inputs
                name
                self
                system
                user
                userConf
                hostname
                secrets
                ;
            };
        }

      else if buildTarget == "nixos-avf" then
        nixosSystem {
          inherit system;
          modules = commonModules ++ nixosModules ++ [ inputs.nixos-avf.nixosModules.avf ];
          specialArgs =
            let
              self = inputs.self;
              user = userConf;
            in
            {
              inherit
                inputs
                name
                self
                system
                user
                userConf
                hostname
                secrets
                ;
            };
        }
      #handles VM builds. Default will not cross compile.
      else if buildTarget == "vm" then
        nixosSystem {
          inherit system;
          modules =
            commonModules
            ++ nixosModules
            ++ [
              (inputs.nixos-generators.nixosModules.all-formats)
            ];
          specialArgs =
            let
              self = inputs.self;
              user = userConf;
            in
            {
              inherit
                inputs
                name
                self
                system
                user
                userConf
                hostname
                secrets
                ;
            };
        }

      else if buildTarget == "darwin" then
        inputs.darwin.lib.darwinSystem {
          inherit system;
          modules = commonModules ++ darwinModules;
          specialArgs =
            let
              self = inputs.self;
              user = userConf;
            in
            {
              inherit
                inputs
                name
                self
                system
                user
                userConf
                secrets
                pkgs
                ;
            };
        }
      else
        throw "${systemType} is not supported."
    );

  ################################## DROID ##################################
  # mkNixOnDroidConfiguration =
  # name:
  # {
  #   config ? name,
  #   user ? "",
  #   system ? "aarch64-linux",
  #   hostname ? "nix-on-droid",
  #   args ? { },
  # }:
  # nameValuePair name (
  #   let
  #     pkgs = import nixpkgs {
  #       system = "aarch64-linux";
  #       overlays = [
  #         nix-on-droid.overlays.default
  #         # add other overlays
  #       ];
  #     };
  #     userConf = import (strToFile user ../users);
  #   in
  #   nix-on-droid.lib.nixOnDroidConfiguration {
  #     inherit system pkgs;
  #     modules = [
  #       (
  #         { pkgs, ... }:
  #         {
  #           # Don't rely on the configuration to enable a flake-compatible version of Nix.
  #           nix = {
  #             package = pkgs.nixVersions.stable;
  #             extraOptions = "experimental-features = nix-command flakes";
  #           };
  #         }
  #       )

  #       (
  #         { inputs, ... }:
  #         {
  #           # Re-expose self and nixpkgs as flakes.
  #           nix.registry = {
  #             self.flake = inputs.self;
  #             nixpkgs = {
  #               from = {
  #                 id = "nixpkgs";
  #                 type = "indirect";
  #               };
  #               flake = inputs.nixpkgs;
  #             };
  #           };
  #         }
  #       )
  #       (
  #         { ... }:
  #         {
  #           environment.etcBackupExtension = ".bak";
  #           system.stateVersion = "24.05";
  #         }
  #       )
  #       ({
  #         home-manager = {
  #           # useUserPackages = true;
  #           config = ../home/droid/home.nix;
  #           useGlobalPkgs = true;
  #           extraSpecialArgs =
  #             let
  #               self = inputs.self;
  #               user = userConf;
  #             in
  #             # NOTE: Cannot pass name to home-manager as it passes `name` in to set the `hmModule`
  #             {
  #               inherit
  #                 inputs
  #                 self
  #                 system
  #                 user
  #                 userConf
  #                 # secrets
  #                 ;
  #             };
  #         };
  #       })
  #       (import (strToPath config ../system/droid/hosts))

  #     ];
  #     extraSpecialArgs =
  #       let
  #         self = inputs.self;
  #         user = userConf;
  #       in
  #       {
  #         inherit
  #           inputs
  #           self
  #           system
  #           user
  #           userConf
  #           # secrets
  #           agenix
  #           home-manager
  #           ;
  #       };
  #   }
  # );
}
