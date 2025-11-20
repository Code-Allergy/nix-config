# TODO
# harden system - firejail, apparmor, etc
{
  description = "Ryan's Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";

    catppuccin.url = "github:catppuccin/nix";

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    # REQUIRES sbctl generate keys at /etc/secureboot
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tsutsumi = {
      url = "github:Fuwn/tsutsumi";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland WM
    # hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    # disko.url = "github:nix-community/disko";
    # ags.url = "github:Aylur/ags"; # TODO switch to AGS over waybar.
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-flatpak,
      lanzaboote,
      catppuccin,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      # Supported systems for your flake packages, shell, etc.
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      mkNixosSystem =
        {
          hostname,
          username,
          isHeaded ? true,
        }:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
            inherit hostname username isHeaded;
          };
          modules = [
            lanzaboote.nixosModules.lanzaboote
            nix-flatpak.nixosModules.nix-flatpak
            ./cachix.nix
            ./modules/nixos
            ./nixos/common.nix
            (./hosts + "/${hostname}")
            # Conditional headed/headless configuration
            (if isHeaded then ./nixos/headed.nix else ./nixos/headless.nix)

            ./nixos/users/${username}
            catppuccin.nixosModules.catppuccin
            # Home-manager module
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit
                  inputs
                  outputs
                  hostname
                  isHeaded
                  ;
              };
              home-manager.users.${username} = {
                imports = [
                  ./home/${username}/home.nix
                  ./modules/home-manager
                  catppuccin.homeModules.catppuccin
                ];
              };
            }
          ];
        };

      # Function to create a home-manager configuration
      mkHomeConfiguration =
        {
          system,
          username,
          isHeaded ? true,
          configName ? username, # Allows us to have username "aliases" for different configurations
          homeDirectory ? null,
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = {
            inherit inputs outputs;
            inherit isHeaded username;
          };
          modules = [
            ./home/${configName}/home.nix

            {
              home = {
                inherit username;
                homeDirectory =
                  if homeDirectory != null then
                    homeDirectory
                  else if nixpkgs.lib.hasPrefix "darwin" system then
                    "/Users/${username}"
                  else
                    "/home/${username}";
              };
            }
          ];
        };
    in
    {
      # Your custom packages
      # Accessible through 'nix build', 'nix shell', etc
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      # Formatter for your nix files, available through 'nix fmt'
      # Other options beside 'alejandra' include 'nixpkgs-fmt'
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };

      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules = import ./modules/nixos;
      # Reusable home-manager modules you might want to export
      # These are usually stuff you would upstream into home-manager
      homeManagerModules = import ./modules/home-manager;

      nixosConfigurations = {
        bigblubbus = mkNixosSystem {
          hostname = "bigblubbus";
          username = "ryan";
          isHeaded = true;
        };
        blubbus = mkNixosSystem {
          hostname = "blubbus";
          username = "ryan";
          isHeaded = true;
        };
      };

      homeConfigurations = forAllSystems (system: {
        "ryan" = mkHomeConfiguration {
          inherit system;
          username = "ryan";
        };

        # Tuxworld nix-home configuration
        "rys686" = mkHomeConfiguration {
          inherit system;
          username = "rys686";
          configName = "ryan";
          homeDirectory = "/student/rys686";
          isHeaded = false;
        };
        # Add more configurations as needed
      });
    };
}
